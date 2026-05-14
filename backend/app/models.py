from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    full_name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    phone = Column(String, nullable=False)

    password_hash = Column(String, nullable=False)

    company = Column(String, nullable=True)
    position = Column(String, nullable=True)

    is_admin = Column(Boolean, default=False)

    created_at = Column(DateTime, default=datetime.utcnow)

    tickets = relationship("Ticket", back_populates="user")


class Ticket(Base):
    __tablename__ = "tickets"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"))

    app_request_id = Column(String, nullable=True)

    lead_id = Column(Integer, nullable=True)
    deal_id = Column(Integer, nullable=True)

    full_name = Column(String, nullable=False)
    email = Column(String, nullable=False)
    phone = Column(String, nullable=False)

    company = Column(String, nullable=True)
    position = Column(String, nullable=True)

    event_name = Column(String, nullable=True)

    barcode = Column(String, nullable=True)
    ticket_pdf_url = Column(Text, nullable=True)

    status = Column(String, default="created")
    comment = Column(Text, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="tickets")


class Exhibitor(Base):
    __tablename__ = "exhibitors"

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String(255), nullable=False)

    description = Column(Text, nullable=True)

    category = Column(String(255), nullable=True)

    stand_number = Column(String(100), nullable=True)

    country = Column(String(100), nullable=True)

    city = Column(String(100), nullable=True)

    website = Column(String(255), nullable=True)

    phone = Column(String(50), nullable=True)

    email = Column(String(255), nullable=True)

    logo_url = Column(Text, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)