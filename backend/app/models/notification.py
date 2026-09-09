from sqlalchemy import Boolean, Enum, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base, TimestampMixin
from .enums import NotificationKind


class Notification(Base, TimestampMixin):
    __tablename__ = "notifications"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    kind: Mapped[NotificationKind] = mapped_column(
        Enum(NotificationKind, name="notification_kind")
    )
    title: Mapped[str] = mapped_column(String(120))
    body: Mapped[str] = mapped_column(String(240), default="")

    # Bosilganda ochiladigan e'lon — bo'lmasligi ham mumkin
    listing_id: Mapped[int | None] = mapped_column(
        ForeignKey("listings.id", ondelete="SET NULL")
    )
    unread: Mapped[bool] = mapped_column(Boolean, default=True, index=True)
