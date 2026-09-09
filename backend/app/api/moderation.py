from datetime import UTC, datetime, timedelta
from typing import Annotated

from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import func, select

from ..deps import Moderator, Session
from ..models import Listing, ListingStatus, Notification, NotificationKind, User
from ..schemas.common import Ok, Page
from ..schemas.listing import ListingCard, ListingOut, RejectIn
from ._convert import to_card, to_detail
from .listings import LISTING_TTL_DAYS

router = APIRouter(prefix="/moderation", tags=["moderation"])


@router.get("/queue", response_model=Page[ListingCard])
async def queue(
    session: Session,
    _: Moderator,
    limit: Annotated[int, Query(ge=1, le=50)] = 20,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> Page[ListingCard]:
    """Tekshirilishi kerak bo'lgan e'lonlar — eng eskisi birinchi."""
    where = Listing.status == ListingStatus.moderation
    total = await session.scalar(
        select(func.count()).select_from(Listing).where(where)
    )
    items = list(
        await session.scalars(
            select(Listing)
            .where(where)
            .order_by(Listing.created_at.asc())
            .limit(limit)
            .offset(offset)
        )
    )
    return Page(
        items=[to_card(i, set()) for i in items],
        total=total or 0,
        limit=limit,
        offset=offset,
    )


@router.get("/listings/{listing_id}", response_model=ListingOut)
async def review(listing_id: int, session: Session, _: Moderator) -> ListingOut:
    listing = await session.get(Listing, listing_id)
    if listing is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Eʼlon topilmadi")
    owner = await session.get(User, listing.owner_id)
    return to_detail(listing, owner, 0, False)


@router.post("/listings/{listing_id}/approve", response_model=Ok)
async def approve(listing_id: int, session: Session, _: Moderator) -> Ok:
    listing = await session.get(Listing, listing_id)
    if listing is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Eʼlon topilmadi")

    now = datetime.now(UTC)
    listing.status = ListingStatus.active
    listing.reject_reason = None
    listing.published_at = now
    listing.expires_at = now + timedelta(days=LISTING_TTL_DAYS)

    session.add(
        Notification(
            user_id=listing.owner_id,
            kind=NotificationKind.approved,
            title="Eʼloningiz tasdiqlandi",
            body=listing.title,
            listing_id=listing.id,
        )
    )
    await session.commit()
    return Ok()


@router.post("/listings/{listing_id}/reject", response_model=Ok)
async def reject(
    listing_id: int, payload: RejectIn, session: Session, _: Moderator
) -> Ok:
    listing = await session.get(Listing, listing_id)
    if listing is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Eʼlon topilmadi")

    listing.status = ListingStatus.rejected
    listing.reject_reason = payload.reason

    session.add(
        Notification(
            user_id=listing.owner_id,
            kind=NotificationKind.rejected,
            title="Eʼlon qaytarildi",
            # Sabab foydalanuvchiga ko'rinadi — u tuzatib qayta yuboradi
            body=f"{listing.title} — {payload.reason}",
            listing_id=listing.id,
        )
    )
    await session.commit()
    return Ok()
