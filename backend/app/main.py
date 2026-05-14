import os
import uuid
from io import BytesIO
from typing import List, Optional

import requests
from dotenv import load_dotenv
from fastapi import Depends, FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address
from sqlalchemy.orm import Session

from app.auth_utils import (
    create_access_token,
    decode_access_token,
    hash_password,
    verify_password,
)
from app.database import Base, engine, get_db
from app.models import Ticket, User, Exhibitor
from app.schemas import (
    ExhibitorCreate,
    ExhibitorResponse,
    TicketCreate,
    TicketResponse,
    TokenResponse,
    UserLogin,
    UserRegister,
    UserResponse,
)

load_dotenv()

app = FastAPI(title="Expo Mobile Backend")

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "http://localhost").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)

security = HTTPBearer()

BITRIX_WEBHOOK_URL = os.getenv("BITRIX_WEBHOOK_URL", "").rstrip("/")

BITRIX_PDF_PROXY_URL = "https://euroshoes.center/tools/mobile-ticket-pdf.php"
BITRIX_PDF_SECRET = "MOBILE_TICKET_SECRET_2026_8fd9a7sdf8923"
ADMIN_SECRET = os.getenv("ADMIN_SECRET", "")

LEAD_APP_REQUEST_FIELD = "UF_CRM_1777835709"
DEAL_APP_REQUEST_FIELD = "UF_CRM_1777835756"

DEAL_BARCODE_FIELD = "UF_CRM_1733480586"
DEAL_PDF_FIELD = "UF_CRM_1733480606"


def bitrix_call(method: str, payload: Optional[dict] = None) -> dict:
    if not BITRIX_WEBHOOK_URL:
        raise HTTPException(status_code=500, detail="BITRIX_WEBHOOK_URL is not configured")

    url = f"{BITRIX_WEBHOOK_URL}/{method}.json"

    try:
        response = requests.post(url, json=payload or {}, timeout=30)
    except requests.RequestException as exc:
        raise HTTPException(status_code=502, detail=f"Bitrix request error: {exc}")

    if response.status_code != 200:
        raise HTTPException(status_code=502, detail=response.text)

    data = response.json()

    if "error" in data:
        raise HTTPException(status_code=502, detail=data)

    return data


def extract_file_id(file_data) -> Optional[int]:
    if not file_data:
        return None

    if isinstance(file_data, list):
        if not file_data:
            return None
        file_data = file_data[0]

    if isinstance(file_data, dict):
        file_id = file_data.get("id") or file_data.get("ID")
        return int(file_id) if file_id else None

    try:
        return int(file_data)
    except Exception:
        return None


def get_user_by_token(token: str, db: Session) -> User:
    payload = decode_access_token(token)

    if not payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    user_id = payload.get("sub")

    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token payload")

    user = db.query(User).filter(User.id == int(user_id)).first()

    if not user:
        raise HTTPException(status_code=401, detail="User not found")

    return user


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    return get_user_by_token(credentials.credentials, db)

def get_current_admin(
    current_user: User = Depends(get_current_user),
) -> User:
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Admin access required")

    return current_user


def sync_ticket_from_bitrix(ticket: Ticket, db: Session) -> Ticket:
    deal_list = bitrix_call(
        "crm.deal.list",
        {
            "filter": {
                DEAL_APP_REQUEST_FIELD: ticket.app_request_id,
            },
            "select": [
                "ID",
                "TITLE",
                DEAL_APP_REQUEST_FIELD,
                DEAL_BARCODE_FIELD,
                DEAL_PDF_FIELD,
            ],
            "order": {
                "ID": "DESC",
            },
        },
    )

    deals = deal_list.get("result", [])

    if not deals:
        ticket.status = "waiting_bitrix_deal"
        ticket.comment = "Сделка в Bitrix24 пока не найдена"
        db.commit()
        db.refresh(ticket)
        return ticket

    deal_id = int(deals[0]["ID"])

    deal_get = bitrix_call("crm.deal.get", {"id": deal_id})
    deal_data = deal_get.get("result", {})

    barcode = deal_data.get(DEAL_BARCODE_FIELD)
    pdf_field = deal_data.get(DEAL_PDF_FIELD)
    file_id = extract_file_id(pdf_field)

    ticket.deal_id = deal_id
    ticket.barcode = barcode

    if file_id:
        ticket.status = "ticket_ready"
        ticket.ticket_pdf_url = f"{BITRIX_PDF_PROXY_URL}?file_id={file_id}"
        ticket.comment = "Готовый билет получен из Bitrix24"
    else:
        ticket.status = "waiting_ticket_pdf"
        ticket.ticket_pdf_url = None
        ticket.comment = "Сделка найдена, но PDF билета пока не готов"

    db.commit()
    db.refresh(ticket)

    return ticket


@app.get("/")
def root():
    return {"status": "ok", "message": "Expo backend is running"}


@app.post("/api/auth/register", response_model=TokenResponse)
@limiter.limit("5/minute")
def register_user(request: Request, data: UserRegister, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == data.email).first()

    if existing_user:
        raise HTTPException(status_code=400, detail="Пользователь с таким Email уже существует")

    user = User(
        full_name=data.full_name,
        email=data.email,
        phone=data.phone,
        password_hash=hash_password(data.password),
        company=data.company,
        position=data.position,
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    access_token = create_access_token({"sub": str(user.id)})

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user,
    }


@app.post("/api/auth/login", response_model=TokenResponse)
@limiter.limit("10/minute")
def login_user(request: Request, data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()

    if not user or not verify_password(data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Неверный Email или пароль")

    access_token = create_access_token({"sub": str(user.id)})

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user,
    }


@app.get("/api/profile", response_model=UserResponse)
def get_profile(current_user: User = Depends(get_current_user)):
    return current_user


@app.post("/api/ticket", response_model=TicketResponse)
def create_ticket(
    data: TicketCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    app_request_id = f"APP-{uuid.uuid4().hex[:12].upper()}"

    payload = {
        "fields": {
            "TITLE": f"Заявка на пригласительный билет — {data.full_name}",
            "NAME": data.full_name,
            "PHONE": [{"VALUE": data.phone, "VALUE_TYPE": "WORK"}],
            "EMAIL": [{"VALUE": data.email, "VALUE_TYPE": "WORK"}],
            "COMPANY_TITLE": data.company,
            "POST": data.position,
            "SOURCE_ID": "WEB",
            LEAD_APP_REQUEST_FIELD: app_request_id,
            "COMMENTS": (
                "Заявка создана из мобильного приложения.\n"
                f"APP_REQUEST_ID: {app_request_id}\n"
                f"ID пользователя в приложении: {current_user.id}\n"
                f"ФИО: {data.full_name}\n"
                f"Телефон: {data.phone}\n"
                f"Email: {data.email}\n"
                f"Компания: {data.company}\n"
                f"Должность: {data.position}"
            ),
        },
        "params": {"REGISTER_SONET_EVENT": "Y"},
    }

    lead_response = bitrix_call("crm.lead.add", payload)
    lead_id = lead_response.get("result")

    ticket = Ticket(
        user_id=current_user.id,
        app_request_id=app_request_id,
        lead_id=lead_id,
        deal_id=None,
        full_name=data.full_name,
        email=data.email,
        phone=data.phone,
        company=data.company,
        position=data.position,
        event_name="Euro Shoes Premiere Collection",
        barcode=None,
        ticket_pdf_url=None,
        status="created",
        comment="Лид создан в Bitrix24. Ожидается создание сделки и PDF билета.",
    )

    db.add(ticket)
    db.commit()
    db.refresh(ticket)

    return ticket


@app.get("/api/tickets", response_model=List[TicketResponse])
def get_my_tickets(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    tickets = (
        db.query(Ticket)
        .filter(Ticket.user_id == current_user.id)
        .order_by(Ticket.created_at.desc())
        .all()
    )

    synced_tickets = []

    for ticket in tickets:
        if ticket.status != "ticket_ready":
            ticket = sync_ticket_from_bitrix(ticket, db)
        synced_tickets.append(ticket)

    return synced_tickets


@app.post("/api/tickets/{ticket_id}/sync", response_model=TicketResponse)
def sync_ticket(
    ticket_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    ticket = (
        db.query(Ticket)
        .filter(Ticket.id == ticket_id, Ticket.user_id == current_user.id)
        .first()
    )

    if not ticket:
        raise HTTPException(status_code=404, detail="Билет не найден")

    return sync_ticket_from_bitrix(ticket, db)


@app.get("/api/tickets/{ticket_id}/pdf")
def download_ticket_pdf(
    ticket_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    ticket = (
        db.query(Ticket)
        .filter(Ticket.id == ticket_id, Ticket.user_id == current_user.id)
        .first()
    )

    if not ticket:
        raise HTTPException(status_code=404, detail="Билет не найден")

    ticket = sync_ticket_from_bitrix(ticket, db)

    if not ticket.deal_id:
        raise HTTPException(status_code=404, detail="Сделка Bitrix24 пока не найдена")

    deal_get = bitrix_call("crm.deal.get", {"id": ticket.deal_id})
    deal_data = deal_get.get("result", {})

    file_id = extract_file_id(deal_data.get(DEAL_PDF_FIELD))

    if not file_id:
        raise HTTPException(status_code=404, detail="PDF файл в сделке пока не найден")

    try:
        response = requests.get(
            BITRIX_PDF_PROXY_URL,
            params={
                "secret": BITRIX_PDF_SECRET,
                "file_id": file_id,
            },
            timeout=30,
        )
    except requests.RequestException as exc:
        raise HTTPException(status_code=502, detail=f"Ошибка загрузки PDF: {exc}")

    if response.status_code != 200:
        raise HTTPException(
            status_code=502,
            detail=f"Bitrix PDF proxy error {response.status_code}: {response.text[:300]}",
        )

    content_type = response.headers.get("content-type", "").lower()

    if "application/pdf" not in content_type:
        raise HTTPException(
            status_code=502,
            detail=f"Bitrix вернул не PDF: {response.text[:300]}",
        )

    return StreamingResponse(
        BytesIO(response.content),
        media_type="application/pdf",
        headers={
            "Content-Disposition": f'inline; filename="ticket_{ticket.id}.pdf"'
        },
    )
def check_admin_secret(admin_secret: str):
    if not ADMIN_SECRET:
        raise HTTPException(status_code=500, detail="ADMIN_SECRET is not configured")

    if admin_secret != ADMIN_SECRET:
        raise HTTPException(status_code=403, detail="Invalid admin secret")


@app.get("/api/exhibitors", response_model=List[ExhibitorResponse])
def get_exhibitors(
    search: Optional[str] = None,
    category: Optional[str] = None,
    db: Session = Depends(get_db),
):
    query = db.query(Exhibitor)

    if search:
        query = query.filter(Exhibitor.name.ilike(f"%{search}%"))

    if category:
        query = query.filter(Exhibitor.category == category)

    return query.order_by(Exhibitor.name.asc()).all()


@app.get("/api/exhibitors/{exhibitor_id}", response_model=ExhibitorResponse)
def get_exhibitor(
    exhibitor_id: int,
    db: Session = Depends(get_db),
):
    exhibitor = db.query(Exhibitor).filter(Exhibitor.id == exhibitor_id).first()

    if not exhibitor:
        raise HTTPException(status_code=404, detail="Участник не найден")

    return exhibitor


@app.post("/api/admin/exhibitors", response_model=ExhibitorResponse)
def create_exhibitor(
    data: ExhibitorCreate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin),
):
    exhibitor = Exhibitor(
        name=data.name,
        description=data.description,
        category=data.category,
        stand_number=data.stand_number,
        country=data.country,
        city=data.city,
        website=data.website,
        phone=data.phone,
        email=data.email,
        logo_url=data.logo_url,
    )

    db.add(exhibitor)
    db.commit()
    db.refresh(exhibitor)

    return exhibitor


@app.delete("/api/admin/exhibitors/{exhibitor_id}")
def delete_exhibitor(
    exhibitor_id: int,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin),
):
    exhibitor = db.query(Exhibitor).filter(Exhibitor.id == exhibitor_id).first()

    if not exhibitor:
        raise HTTPException(status_code=404, detail="Участник не найден")

    db.delete(exhibitor)
    db.commit()

    return {"success": True, "message": "Участник удален"}

@app.put("/api/admin/exhibitors/{exhibitor_id}", response_model=ExhibitorResponse)
def update_exhibitor(
        exhibitor_id: int,
        data: ExhibitorCreate,
        db: Session = Depends(get_db),
        current_admin: User = Depends(get_current_admin),
    ):
        exhibitor = db.query(Exhibitor).filter(Exhibitor.id == exhibitor_id).first()

        if not exhibitor:
            raise HTTPException(status_code=404, detail="Участник не найден")

        exhibitor.name = data.name
        exhibitor.description = data.description
        exhibitor.category = data.category
        exhibitor.stand_number = data.stand_number
        exhibitor.country = data.country
        exhibitor.city = data.city
        exhibitor.website = data.website
        exhibitor.phone = data.phone
        exhibitor.email = data.email
        exhibitor.logo_url = data.logo_url

        db.commit()
        db.refresh(exhibitor)

        return exhibitor
@app.get("/api/admin/users", response_model=List[UserResponse])
def admin_get_users(
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin),
):
    users = db.query(User).order_by(User.created_at.desc()).all()
    return users
@app.put("/api/admin/users/{user_id}/admin", response_model=UserResponse)
def admin_set_user_admin(
    user_id: int,
    is_admin: bool,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin),
):
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="Пользователь не найден")

    user.is_admin = is_admin

    db.commit()
    db.refresh(user)

    return user