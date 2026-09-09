from pydantic import BaseModel, Field


class UserOut(BaseModel):
    id: int
    name: str | None
    phone: str
    district: str | None
    member_since: int
    phone_verified: bool

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
    active_listings: int
    total_views: int
    favorites: int


class MeOut(BaseModel):
    user: UserOut
    stats: ProfileStats


class PhoneOut(BaseModel):
    phone: str
