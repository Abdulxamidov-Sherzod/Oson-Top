from datetime import datetime

from pydantic import BaseModel, Field

from ..models.enums import UserRole


class ModerationCounts(BaseModel):
    """Panel bo'limlari ustidagi sonlar."""

    moderation: int
    active: int
    rejected: int


class UserRow(BaseModel):
    """Panel foydalanuvchilar ro'yxatidagi bitta qator."""

    id: int
    name: str | None
    phone: str | None
    telegram_username: str | None
    district: str | None
    role: UserRole
    is_blocked: bool
    listing_count: int
    created_at: datetime
    last_seen_at: datetime | None

    model_config = {"from_attributes": True}


class UserCounts(BaseModel):
    """Foydalanuvchilar bo'limi ustidagi sonlar."""

    total: int
    staff: int
    blocked: int


class RoleIn(BaseModel):
    role: UserRole


class BlockIn(BaseModel):
    blocked: bool


class PushIn(BaseModel):
    title: str = Field(..., min_length=2, max_length=120)
    body: str = Field("", max_length=240)

    # Bo'sh bo'lsa — hamma foydalanuvchiga
    user_id: int | None = None


class PushOut(BaseModel):
    """Yuborilgandan keyingi hisobot."""

    users: int
    devices: int
