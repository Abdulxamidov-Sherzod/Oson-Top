from datetime import datetime

from sqlalchemy import BigInteger, Boolean, DateTime, Enum, Integer, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, TimestampMixin
from .enums import UserRole


class User(Base, TimestampMixin):
    """Foydalanuvchi. Parol yo'q — kirish faqat SMS kodi orqali."""

    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)

    # Telegram foydalanuvchi id'si — kirish shu orqali
    telegram_id: Mapped[int | None] = mapped_column(
        BigInteger, unique=True, index=True
    )
    telegram_username: Mapped[str | None] = mapped_column(String(64))

    # +998901234567. Telegram'dan olinadi ("Raqamni ulashish"), shuning uchun
    # tasdiqlangan hisoblanadi. Xaridor shu raqamga qo'ng'iroq qiladi.
    phone: Mapped[str | None] = mapped_column(String(16), unique=True, index=True)

    name: Mapped[str | None] = mapped_column(String(80))
    district: Mapped[str | None] = mapped_column(String(64))
    role: Mapped[UserRole] = mapped_column(
        Enum(UserRole, name="user_role"), default=UserRole.user
    )

    # Raqam Telegram orqali tasdiqlangani — ilovada "✓ Raqam tasdiqlangan" shu
    phone_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    is_blocked: Mapped[bool] = mapped_column(Boolean, default=False)

    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    listings = relationship("Listing", back_populates="owner", lazy="raise")

    @property
    def member_since(self) -> int:
        return self.created_at.year if self.created_at else func.now()
