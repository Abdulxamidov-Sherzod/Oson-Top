from datetime import UTC, datetime
from typing import Annotated

from fastapi import APIRouter, Query
from sqlalchemy import delete, func, select

from ..deps import CurrentUser, Session
from ..models import DeviceToken, Favorite, Listing, ListingStatus
from ..reference import DISTRICT_SET
from ..schemas.common import Ok, Page
from ..schemas.listing import ListingCard
from ..schemas.user import DeviceIn, MeOut, ProfileIn, ProfileStats, UserOut
from ._convert import to_card

router = APIRouter(prefix="/me", tags=["me"])


def _user_out(user) -> UserOut:
    return UserOut(
        id=user.id,
        name=user.name,
        phone=user.phone,
        district=user.district,
        member_since=user.created_at.year,
        phone_verified=user.phone_verified,
        role=user.role,
    )


@router.get("", response_model=MeOut)
async def profile(session: Session, user: CurrentUser) -> MeOut:
    active = await session.scalar(
        select(func.count())
        .select_from(Listing)
        .where(Listing.owner_id == user.id, Listing.status == ListingStatus.active)
    )
    total = await session.scalar(
        select(func.count())
        .select_from(Listing)
        .where(Listing.owner_id == user.id)
    )
    views = await session.scalar(
        select(func.coalesce(func.sum(Listing.views), 0)).where(
            Listing.owner_id == user.id
        )
    )
    saved = await session.scalar(
        select(func.count()).select_from(Favorite).where(Favorite.user_id == user.id)
    )
    return MeOut(
        user=_user_out(user),
        stats=ProfileStats(
            active_listings=active or 0,
            total_listings=total or 0,
            total_views=views or 0,
            favorites=saved or 0,
        ),
    )


@router.patch("", response_model=UserOut)
async def update_profile(
    payload: ProfileIn, session: Session, user: CurrentUser
) -> UserOut:
    if payload.name is not None:
        user.name = payload.name.strip() or None
    if payload.district is not None:
        user.district = payload.district if payload.district in DISTRICT_SET else None
    await session.commit()
    return _user_out(user)


@router.get("/listings", response_model=Page[ListingCard])
async def my_listings(
    session: Session,
    user: CurrentUser,
    limit: Annotated[int, Query(ge=1, le=50)] = 20,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> Page[ListingCard]:
    """Mening e'lonlarim — hamma holatdagilari, moderatsiyadagisi ham."""
    total = await session.scalar(
        select(func.count()).select_from(Listing).where(Listing.owner_id == user.id)
    )
    items = list(
        await session.scalars(
            select(Listing)
            .where(Listing.owner_id == user.id)
            .order_by(Listing.created_at.desc())
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


@router.put("/devices", response_model=Ok)
async def register_device(
    payload: DeviceIn, session: Session, user: CurrentUser
) -> Ok:
    """Push uchun qurilma tokenini saqlash.

    Token qurilmaga tegishli, hisobga emas: boshqa hisob bilan kirilsa, u
    yangi egasiga oʻtadi. Aks holda push telefonni tark etgan odamga
    ketaverardi.
    """
    existing = await session.scalar(
        select(DeviceToken).where(DeviceToken.token == payload.token)
    )
    now = datetime.now(UTC)
    if existing is None:
        session.add(
            DeviceToken(
                user_id=user.id,
                token=payload.token,
                platform=payload.platform,
                last_seen_at=now,
            )
        )
    else:
        existing.user_id = user.id
        existing.platform = payload.platform
        existing.last_seen_at = now
    await session.commit()
    return Ok()


@router.delete("/devices/{token}", response_model=Ok)
async def forget_device(token: str, session: Session, user: CurrentUser) -> Ok:
    """Chiqishda chaqiriladi — bu qurilmaga endi push kelmasin."""
    await session.execute(
        delete(DeviceToken).where(
            DeviceToken.token == token, DeviceToken.user_id == user.id
        )
    )
    await session.commit()
    return Ok()
