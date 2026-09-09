from datetime import datetime

from pydantic import BaseModel, Field, field_validator

from ..models.enums import ListingCondition, ListingStatus
from ..reference import CATEGORY_IDS, DISTRICT_SET
from .user import SellerOut


class SpecIn(BaseModel):
    label: str = Field(..., max_length=40)
    value: str = Field(..., max_length=80)


class SpecOut(SpecIn):
    pass


class PhotoOut(BaseModel):
    id: int
    url: str
    thumb_url: str
    width: int
    height: int


class ListingCard(BaseModel):
    """Lentadagi karta uchun — batafsil sahifadan kamroq maydon."""

    id: int
    title: str
    price: int
    price_unit: str | None
    category_id: str
    district: str
    created_at: datetime
    photo: str | None
    is_favorite: bool = False

    model_config = {"from_attributes": True}


class ListingOut(BaseModel):
    id: int
    title: str
    description: str
    price: int
    price_unit: str | None
    category_id: str
    condition: ListingCondition
    district: str
    address: str | None
    lat: float | None
    lng: float | None
    status: ListingStatus
    reject_reason: str | None
    views: int
    created_at: datetime
    photos: list[PhotoOut]
    specs: list[SpecOut]
    seller: SellerOut
    is_favorite: bool = False

    model_config = {"from_attributes": True}


class ListingIn(BaseModel):
    title: str = Field(..., min_length=3, max_length=70)
    description: str = Field("", max_length=2000)
    # 0 — "Kelishiladi"
    price: int = Field(0, ge=0, le=100_000_000_000)
    price_unit: str | None = Field(None, pattern="^(oy)$")
    category_id: str
    condition: ListingCondition = ListingCondition.used
    district: str
    address: str | None = Field(None, max_length=160)
    lat: float | None = Field(None, ge=-90, le=90)
    lng: float | None = Field(None, ge=-180, le=180)
    photo_ids: list[int] = Field(default_factory=list, max_length=8)
    specs: list[SpecIn] = Field(default_factory=list, max_length=12)

    @field_validator("category_id")
    @classmethod
    def _category(cls, v: str) -> str:
        if v not in CATEGORY_IDS:
            raise ValueError("Bunday kategoriya yo'q")
        return v

    @field_validator("district")
    @classmethod
    def _district(cls, v: str) -> str:
        if v not in DISTRICT_SET:
            raise ValueError("Bunday tuman yo'q")
        return v


class RejectIn(BaseModel):
    reason: str = Field(..., min_length=3, max_length=200)
