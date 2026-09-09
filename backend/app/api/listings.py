from datetime import UTC, datetime, timedelta
from typing import Annotated, Literal

from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import func, or_, select

from ..config import settings
from ..deps import CurrentUser, OptionalUser, Session
from ..models import (
    Favorite,
    Listing,
    ListingCondition,
    ListingPhoto,
    ListingSpec,
    ListingStatus,
    User,
)
from ..schemas.common import Ok, Page
from ..schemas.listing import ListingCard, ListingIn, ListingOut
from ..schemas.user import PhoneOut
from ._convert import to_card, to_detail

router = APIRouter(prefix="/listings", tags=["listings"])

# E'lon shuncha kundan keyin arxivga tushadi
LISTING_TTL_DAYS = 30

Sort = Literal["new", "cheap", "expensive"]


async def _favorite_ids(
    session: Session, user: User | None, listing_ids: list[int]
) -> set[int]:
    if user is None or not listing_ids:
        return set()
    rows = await session.scalars(
        select(Favorite.listing_id).where(
            Favorite.user_id == user.id,
            Favorite.listing_id.in_(listing_ids),
        )
    )
    return set(rows)


@router.get("", response_model=Page[ListingCard])
async def feed(
    session: Session,
    user: OptionalUser,
    q: Annotated[str | None, Query(max_length=80)] = None,
    category_id: str | None = None,
    district: str | None = None,
    price_min: Annotated[int | None, Query(ge=0)] = None,
    price_max: Annotated[int | None, Query(ge=0)] = None,
    condition: ListingCondition | None = None,
    sort: Sort = "new",
    limit: Annotated[int, Query(ge=1, le=50)] = 20,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> Page[ListingCard]:
    """Lenta va qidiruv. Faqat tasdiqlangan e'lonlar chiqadi."""
    where = [Listing.status == ListingStatus.active]

    if q:
        pattern = f"%{q.strip()}%"
        where.append(
            or_(Listing.title.ilike(pattern), Listing.description.ilike(pattern))
        )
    if category_id:
        where.append(Listing.category_id == category_id)
    if district:
        where.append(Listing.district == district)
    if condition:
        where.append(Listing.condition == condition)
    # "Kelishiladi" (0) narx filtriga tushmaydi — narxi noma'lum
    if price_min is not None:
        where.append(Listing.price >= price_min)
    if price_max is not None:
        where.append(Listing.price > 0)
        where.append(Listing.price <= price_max)

    total = await session.scalar(
        select(func.count()).select_from(Listing).where(*where)
    )

    order = {
        "new": Listing.created_at.desc(),
        "cheap": Listing.price.asc(),
        "expensive": Listing.price.desc(),
    }[sort]

    items = list(
        await session.scalars(
            select(Listing)
            .where(*where)
            # Ko'tarilgan e'lonlar tepada
            .order_by(Listing.is_promoted.desc(), order, Listing.id.desc())
            .limit(limit)
            .offset(offset)
        )
    )

    favorites = await _favorite_ids(session, user, [i.id for i in items])
    return Page(
        items=[to_card(i, favorites) for i in items],
        total=total or 0,
        limit=limit,
        offset=offset,
    )


@router.get("/{listing_id}", response_model=ListingOut)
async def detail(listing_id: int, session: Session, user: OptionalUser) -> ListingOut:
    listing = await session.get(Listing, listing_id)
    if listing is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Eʼlon topilmadi")

    owner = await session.get(User, listing.owner_id)
    is_owner = user is not None and user.id == listing.owner_id
    is_staff = user is not None and user.role.value in ("moderator", "admin")

    # Moderatsiyadagi yoki rad etilgan e'lonni faqat egasi va moderator ko'radi
    if listing.status != ListingStatus.active and not (is_owner or is_staff):
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Eʼlon topilmadi")

    if not is_owner:
        listing.views += 1
        await session.commit()

    count = await session.scalar(
        select(func.count())
        .select_from(Listing)
        .where(
            Listing.owner_id == listing.owner_id,
            Listing.status == ListingStatus.active,
        )
    )
    favorites = await _favorite_ids(session, user, [listing.id])
    return to_detail(listing, owner, count or 0, listing.id in favorites)


@router.post("/{listing_id}/reveal-phone", response_model=PhoneOut)
async def reveal_phone(listing_id: int, session: Session) -> PhoneOut:
    """Sotuvchining raqami. Alohida endpoint — shunda raqam e'lon bilan
    birga tarqalmaydi va nechta odam qiziqqanini sanaymiz."""
    listing = await session.get(Listing, listing_id)
    if listing is None or listing.status != ListingStatus.active:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Eʼlon topilmadi")

    listing.phone_reveals += 1
    owner = await session.get(User, listing.owner_id)
    await session.commit()
    return PhoneOut(phone=owner.phone)


@router.post("", response_model=ListingOut, status_code=status.HTTP_201_CREATED)
async def create(payload: ListingIn, session: Session, user: CurrentUser) -> ListingOut:
    """E'lon joylash. Moderatsiyadan o'tmaguncha lentada ko'rinmaydi."""
    if not payload.photo_ids:
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_ENTITY, "Kamida bitta rasm kerak"
        )

    photos = list(
        await session.scalars(
            select(ListingPhoto).where(
                ListingPhoto.id.in_(payload.photo_ids),
                ListingPhoto.listing_id.is_(None),
            )
        )
    )
    if len(photos) != len(payload.photo_ids):
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST, "Rasmlar topilmadi yoki band"
        )

    now = datetime.now(UTC)
    approved = settings.auto_approve

    listing = Listing(
        owner_id=user.id,
        title=payload.title.strip(),
        description=payload.description.strip(),
        price=payload.price,
        price_unit=payload.price_unit,
        category_id=payload.category_id,
        condition=payload.condition,
        district=payload.district,
        address=payload.address,
        lat=payload.lat,
        lng=payload.lng,
        status=ListingStatus.active if approved else ListingStatus.moderation,
        published_at=now if approved else None,
        expires_at=now + timedelta(days=LISTING_TTL_DAYS) if approved else None,
    )
    session.add(listing)
    await session.flush()

    # Rasmlar tartibi foydalanuvchi yuborgan ketma-ketlikda
    order = {pid: i for i, pid in enumerate(payload.photo_ids)}
    for photo in photos:
        photo.listing_id = listing.id
        photo.position = order[photo.id]

    for i, spec in enumerate(payload.specs):
        session.add(
            ListingSpec(
                listing_id=listing.id,
                label=spec.label,
                value=spec.value,
                position=i,
            )
        )

    await session.commit()
    await session.refresh(listing)
    return to_detail(listing, user, 0, False)


@router.delete("/{listing_id}", response_model=Ok)
async def remove(listing_id: int, session: Session, user: CurrentUser) -> Ok:
    listing = await session.get(Listing, listing_id)
    if listing is None or listing.owner_id != user.id:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Eʼlon topilmadi")
    await session.delete(listing)
    await session.commit()
    return Ok()
