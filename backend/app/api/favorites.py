from typing import Annotated

from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import func, select

from ..deps import CurrentUser, Session
from ..models import Favorite, Listing, ListingStatus
from ..schemas.common import Ok, Page
from ..schemas.listing import ListingCard
from ._convert import to_card

router = APIRouter(prefix="/favorites", tags=["favorites"])


@router.get("", response_model=Page[ListingCard])
async def my_favorites(
    session: Session,
    user: CurrentUser,
    limit: Annotated[int, Query(ge=1, le=50)] = 20,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> Page[ListingCard]:
    base = (
        select(Listing)
        .join(Favorite, Favorite.listing_id == Listing.id)
        .where(Favorite.user_id == user.id, Listing.status == ListingStatus.active)
    )
    total = await session.scalar(
        select(func.count()).select_from(base.subquery())
    )
    items = list(
        await session.scalars(
            base.order_by(Favorite.created_at.desc()).limit(limit).offset(offset)
        )
    )
    ids = {i.id for i in items}
    return Page(
        items=[to_card(i, ids) for i in items],
        total=total or 0,
        limit=limit,
        offset=offset,
    )


@router.put("/{listing_id}", response_model=Ok)
async def add(listing_id: int, session: Session, user: CurrentUser) -> Ok:
    listing = await session.get(Listing, listing_id)
    if listing is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Eʼlon topilmadi")

    exists = await session.scalar(
        select(Favorite).where(
            Favorite.user_id == user.id, Favorite.listing_id == listing_id
        )
    )
    if exists is None:
        session.add(Favorite(user_id=user.id, listing_id=listing_id))
        await session.commit()
    return Ok()


@router.delete("/{listing_id}", response_model=Ok)
async def remove(listing_id: int, session: Session, user: CurrentUser) -> Ok:
    favorite = await session.scalar(
        select(Favorite).where(
            Favorite.user_id == user.id, Favorite.listing_id == listing_id
        )
    )
    if favorite is not None:
        await session.delete(favorite)
        await session.commit()
    return Ok()
