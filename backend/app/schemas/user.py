from pydantic import BaseModel, Field

from ..models.enums import UserRole


class UserOut(BaseModel):
    id: int
    name: str | None
    phone: str
    district: str | None
    member_since: int
    phone_verified: bool
    # Moderatsiya paneli shu maydonga qarab bo'limlarni ko'rsatadi
    role: UserRole = UserRole.user

    model_config = {"from_attributes": True}


class SellerOut(BaseModel):
    """E'lon sahifasidagi sotuvchi. Telefon raqami YO'Q — u alohida
    endpoint orqali, "Raqamni ko'rsatish" bosilganda beriladi."""

    id: int
    name: str | None
    member_since: int
    phone_verified: bool
    listing_count: int

    model_config = {"from_attributes": True}


class ProfileIn(BaseModel):
    name: str | None = Field(None, max_length=80)
    district: str | None = Field(None, max_length=64)


class ProfileStats(BaseModel):
    # Lentada koʻrinayotganlari
    active_listings: int
    # Hammasi — moderatsiyadagi va qaytarilgani ham. "Mening eʼlonlarim"
    # roʻyxati shularni koʻrsatadi, shuning uchun yonidagi son ham shu.
    total_listings: int
    total_views: int
    favorites: int


class MeOut(BaseModel):
    user: UserOut
    stats: ProfileStats


class PhoneOut(BaseModel):
    phone: str


class DeviceIn(BaseModel):
    token: str = Field(..., min_length=10, max_length=255)
    platform: str = Field(..., pattern="^(ios|android)$")
