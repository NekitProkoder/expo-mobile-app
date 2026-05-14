from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr


class UserRegister(BaseModel):
    full_name: str
    email: EmailStr
    phone: str
    password: str

    company: Optional[str] = None
    position: Optional[str] = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: int
    full_name: str
    email: EmailStr
    phone: str

    company: Optional[str] = None
    position: Optional[str] = None

    is_admin: bool = False

    created_at: datetime

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse


class TicketCreate(BaseModel):
    full_name: str
    email: EmailStr
    phone: str

    company: Optional[str] = None
    position: Optional[str] = None


class TicketResponse(BaseModel):
    id: int

    app_request_id: Optional[str] = None

    lead_id: Optional[int] = None
    deal_id: Optional[int] = None

    full_name: str
    email: EmailStr
    phone: str

    company: Optional[str] = None
    position: Optional[str] = None

    event_name: Optional[str] = None

    barcode: Optional[str] = None
    ticket_pdf_url: Optional[str] = None

    status: str
    comment: Optional[str] = None

    created_at: datetime

    class Config:
        from_attributes = True


class ExhibitorCreate(BaseModel):
    name: str

    description: Optional[str] = None

    category: Optional[str] = None

    stand_number: Optional[str] = None

    country: Optional[str] = None

    city: Optional[str] = None

    website: Optional[str] = None

    phone: Optional[str] = None

    email: Optional[EmailStr] = None

    logo_url: Optional[str] = None


class ExhibitorResponse(BaseModel):
    id: int

    name: str

    description: Optional[str] = None

    category: Optional[str] = None

    stand_number: Optional[str] = None

    country: Optional[str] = None

    city: Optional[str] = None

    website: Optional[str] = None

    phone: Optional[str] = None

    email: Optional[EmailStr] = None

    logo_url: Optional[str] = None

    created_at: datetime

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    full_name: str
    phone: str

    company: Optional[str] = None
    position: Optional[str] = None


class PasswordChange(BaseModel):
    old_password: str
    new_password: str

class EventSettingsResponse(BaseModel):
    id: int
    event_name: str
    dates: str
    location: str
    maps_url: str
    address: str
    telegram_url: str
    website_url: str
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class EventSettingsUpdate(BaseModel):
    event_name: str
    dates: str
    location: str
    maps_url: str
    address: str
    telegram_url: str
    website_url: str
