from datetime import datetime

from sqlalchemy import (
    Boolean,
    DateTime,
    Enum,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, TimestampMixin
from .enums import ListingCondition, ListingStatus


class Listing(Base, TimestampMixin):
    __tablename__ = "listings"
    __table_args__ = (
        # Lenta va qidiruvning asosiy yo'llari
        Index("ix_listings_feed", "status", "created_at"),
        Index("ix_listings_category", "status", "category_id", "created_at"),
        Index("ix_listings_district", "status", "district", "created_at"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    owner_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )

    title: Mapped[str] = mapped_column(String(70))
    description: Mapped[str] = mapped_column(Text, default="")

    # So'mda. 0 — "Kelishiladi".
    price: Mapped[int] = mapped_column(Integer, default=0)
    # Davriy narx uchun: "oy". null — bir martalik.
    price_unit: Mapped[str | None] = mapped_column(String(8))

    category_id: Mapped[str] = mapped_column(String(24))
    condition: Mapped[ListingCondition] = mapped_column(
        Enum(ListingCondition, name="listing_condition"),
        default=ListingCondition.used,
    )

    district: Mapped[str] = mapped_column(String(64))
    # Xaritada belgilangan taxminiy nuqta — ixtiyoriy
    address: Mapped[str | None] = mapped_column(String(160))
    lat: Mapped[float | None] = mapped_column(Float)
    lng: Mapped[float | None] = mapped_column(Float)

    status: Mapped[ListingStatus] = mapped_column(
        Enum(ListingStatus, name="listing_status"),
        default=ListingStatus.moderation,
        index=True,
    )
    # Moderator rad etsa — sababi shu yerda, foydalanuvchiga ko'rsatiladi
    reject_reason: Mapped[str | None] = mapped_column(String(200))

    views: Mapped[int] = mapped_column(Integer, default=0)
    # Necha marta "Raqamni ko'rsatish" bosilgan — real qiziqish o'lchovi
    phone_reveals: Mapped[int] = mapped_column(Integer, default=0)

    is_promoted: Mapped[bool] = mapped_column(Boolean, default=False)
    published_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    owner = relationship("User", back_populates="listings", lazy="joined")
    photos = relationship(
        "ListingPhoto",
        back_populates="listing",
        cascade="all, delete-orphan",
        order_by="ListingPhoto.position",
        lazy="selectin",
    )
    specs = relationship(
        "ListingSpec",
        back_populates="listing",
        cascade="all, delete-orphan",
        order_by="ListingSpec.position",
        lazy="selectin",
    )


class ListingPhoto(Base):
    __tablename__ = "listing_photos"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    # Rasm e'londan oldin yuklanadi — forma to'ldirilayotganda allaqachon
    # serverda bo'ladi. E'lon yaratilgunicha bu maydon bo'sh turadi.
    listing_id: Mapped[int | None] = mapped_column(
        ForeignKey("listings.id", ondelete="CASCADE"), index=True, nullable=True
    )
    # media papkasidagi fayl nomi
    filename: Mapped[str] = mapped_column(String(120))
    width: Mapped[int] = mapped_column(Integer, default=0)
    height: Mapped[int] = mapped_column(Integer, default=0)
    # 0 — asosiy rasm, lentada shu ko'rinadi
    position: Mapped[int] = mapped_column(Integer, default=0)

    listing = relationship("Listing", back_populates="photos")


class ListingSpec(Base):
    """E'lon sahifasidagi "Ma'lumotlar" jadvali qatori."""

    __tablename__ = "listing_specs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    listing_id: Mapped[int] = mapped_column(
        ForeignKey("listings.id", ondelete="CASCADE"), index=True
    )
    label: Mapped[str] = mapped_column(String(40))
    value: Mapped[str] = mapped_column(String(80))
    position: Mapped[int] = mapped_column(Integer, default=0)

    listing = relationship("Listing", back_populates="specs")
