from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base, TimestampMixin


class DeviceToken(Base, TimestampMixin):
    """Push yuborish uchun qurilma tokeni (FCM).

    Bitta foydalanuvchida bir nechta qurilma bo'lishi mumkin. Token qurilmaga
    tegishli, shuning uchun u noyob: boshqa hisob bilan kirilsa, token yangi
    egasiga o'tadi — aks holda push eski egasiga ketib qolardi.
    """

    __tablename__ = "device_tokens"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    token: Mapped[str] = mapped_column(String(255), unique=True, index=True)

    # ios | android
    platform: Mapped[str] = mapped_column(String(10))

    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
