from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base, TimestampMixin


class LoginToken(Base, TimestampMixin):
    """Telegram orqali kirish uchun bir martalik token.

    Ilova token so'raydi → foydalanuvchi botni ochadi → bot tokenni
    ko'radi va raqamni so'raydi → foydalanuvchi ulashadi → token
    `user_id` ga bog'lanadi. Ilova shu paytgacha holatni so'rab turadi.
    """

    __tablename__ = "login_tokens"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    token: Mapped[str] = mapped_column(String(48), unique=True, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))

    # Bog'langandan keyin to'ladi
    user_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE")
    )
    # Token bir marta ishlatiladi
    consumed: Mapped[bool] = mapped_column(Boolean, default=False)
