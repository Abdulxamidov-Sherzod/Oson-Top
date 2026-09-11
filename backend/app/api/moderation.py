from datetime import UTC, datetime, timedelta
from typing import Annotated

from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import func, or_, select

from ..deps import Admin, Moderator, Session
from ..models import (
    Listing,
    ListingStatus,
    Notification,
    NotificationKind,
    User,
    UserRole,
)
from ..schemas.common import Ok, Page
from ..schemas.listing import ListingCard, ListingOut, RejectIn
from ..schemas.moderation import (
    BlockIn,
    ModerationCounts,
    PushIn,
    PushOut,
    RoleIn,
    UserCounts,
    UserRow,
)
from ..services import notify
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


@router.get("/counts", response_model=ModerationCounts)
async def counts(session: Session, _: Moderator) -> ModerationCounts:
    """Bo'limlar ustidagi sonlar."""
    rows = await session.execute(
        select(Listing.status, func.count()).group_by(Listing.status)
    )
    by_status = {status: total for status, total in rows}
    return ModerationCounts(
        moderation=by_status.get(ListingStatus.moderation, 0),
        active=by_status.get(ListingStatus.active, 0),
        rejected=by_status.get(ListingStatus.rejected, 0),
    )


@router.get("/listings", response_model=Page[ListingOut])
async def by_status(
    session: Session,
    _: Moderator,
    status_filter: Annotated[ListingStatus, Query(alias="status")] =
        ListingStatus.moderation,
    limit: Annotated[int, Query(ge=1, le=50)] = 20,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> Page[ListingOut]:
    """Holat bo'yicha ro'yxat, to'liq ma'lumot bilan.

    Moderator har bir e'lonning rasmlarini va tavsifini baribir ko'radi,
    shuning uchun ro'yxat qisqartirilmagan holda beriladi — panel har bir
    element uchun alohida so'rov yubormasin.
    """
    where = Listing.status == status_filter
    total = await session.scalar(
        select(func.count()).select_from(Listing).where(where)
    )
    order = (
        Listing.created_at.asc()
        if status_filter == ListingStatus.moderation
        else Listing.created_at.desc()
    )
    items = list(
        await session.scalars(
            select(Listing).where(where).order_by(order).limit(limit).offset(offset)
        )
    )

    # Egalarining aktiv e'lonlari soni — har biri uchun alohida emas,
    # bitta so'rovda
    owner_ids = {i.owner_id for i in items}
    counts: dict[int, int] = {}
    if owner_ids:
        rows = await session.execute(
            select(Listing.owner_id, func.count())
            .where(
                Listing.owner_id.in_(owner_ids),
                Listing.status == ListingStatus.active,
            )
            .group_by(Listing.owner_id)
        )
        counts = dict(rows.all())

    return Page(
        items=[
            to_detail(i, i.owner, counts.get(i.owner_id, 0), False) for i in items
        ],
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

    await notify.to_user(
        session,
        listing.owner_id,
        title="Eʼloningiz tasdiqlandi",
        body=listing.title,
        data={"listing_id": str(listing.id)},
    )
    return Ok()


@router.post("/listings/{listing_id}/revoke", response_model=Ok)
async def revoke(listing_id: int, session: Session, _: Moderator) -> Ok:
    """Tasdiqni bekor qiladi — e'lon lentadan chiqib, navbatga qaytadi.
    Xato tasdiqlangan yoki keyin muammo topilgan e'lonlar uchun."""
    listing = await session.get(Listing, listing_id)
    if listing is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Eʼlon topilmadi")

    listing.status = ListingStatus.moderation
    listing.published_at = None
    listing.expires_at = None

    session.add(
        Notification(
            user_id=listing.owner_id,
            kind=NotificationKind.rejected,
            title="Eʼlon tekshiruvga qaytarildi",
            body=f"{listing.title} — vaqtincha lentadan olib turildi",
            listing_id=listing.id,
        )
    )
    await session.commit()

    await notify.to_user(
        session,
        listing.owner_id,
        title="Eʼlon tekshiruvga qaytarildi",
        body=f"{listing.title} — vaqtincha lentadan olib turildi",
        data={"listing_id": str(listing.id)},
    )
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

    await notify.to_user(
        session,
        listing.owner_id,
        title="Eʼlon qaytarildi",
        body=f"{listing.title} — {payload.reason}",
        data={"listing_id": str(listing.id)},
    )
    return Ok()


# ---------- foydalanuvchilar ----------

STAFF_ROLES = (UserRole.moderator, UserRole.admin)


def _row(user: User, listing_count: int) -> UserRow:
    return UserRow(
        id=user.id,
        name=user.name,
        phone=user.phone,
        telegram_username=user.telegram_username,
        district=user.district,
        role=user.role,
        is_blocked=user.is_blocked,
        listing_count=listing_count,
        created_at=user.created_at,
        last_seen_at=user.last_seen_at,
    )


@router.get("/users", response_model=Page[UserRow])
async def users(
    session: Session,
    _: Moderator,
    q: Annotated[str | None, Query(max_length=64)] = None,
    role: Annotated[UserRole | None, Query()] = None,
    blocked: Annotated[bool | None, Query()] = None,
    limit: Annotated[int, Query(ge=1, le=50)] = 20,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> Page[UserRow]:
    """Ro'yxat — eng yangi ro'yxatdan o'tgani birinchi.

    Qidiruv nom, raqam va Telegram username bo'yicha ishlaydi.
    """
    where = []
    if q and q.strip():
        needle = f"%{q.strip()}%"
        where.append(
            or_(
                User.name.ilike(needle),
                User.phone.ilike(needle),
                User.telegram_username.ilike(needle),
            )
        )
    if role is not None:
        where.append(User.role == role)
    if blocked is not None:
        where.append(User.is_blocked.is_(blocked))

    total = await session.scalar(
        select(func.count()).select_from(User).where(*where)
    )
    items = list(
        await session.scalars(
            select(User)
            .where(*where)
            .order_by(User.created_at.desc(), User.id.desc())
            .limit(limit)
            .offset(offset)
        )
    )

    # E'lonlar soni — har biri uchun alohida so'rov emas, bittada
    counts: dict[int, int] = {}
    if items:
        rows = await session.execute(
            select(Listing.owner_id, func.count())
            .where(Listing.owner_id.in_([u.id for u in items]))
            .group_by(Listing.owner_id)
        )
        counts = dict(rows.all())

    return Page(
        items=[_row(u, counts.get(u.id, 0)) for u in items],
        total=total or 0,
        limit=limit,
        offset=offset,
    )


@router.get("/users/counts", response_model=UserCounts)
async def user_counts(session: Session, _: Moderator) -> UserCounts:
    total = await session.scalar(select(func.count()).select_from(User))
    staff = await session.scalar(
        select(func.count()).select_from(User).where(User.role.in_(STAFF_ROLES))
    )
    blocked = await session.scalar(
        select(func.count()).select_from(User).where(User.is_blocked.is_(True))
    )
    return UserCounts(total=total or 0, staff=staff or 0, blocked=blocked or 0)


async def _target(session: Session, user_id: int, me: User) -> User:
    if user_id == me.id:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST, "O'zingizga o'zgartirish kirita olmaysiz"
        )
    user = await session.get(User, user_id)
    if user is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Foydalanuvchi topilmadi")
    return user


@router.patch("/users/{user_id}/role", response_model=UserRow)
async def set_role(
    user_id: int, payload: RoleIn, session: Session, me: Admin
) -> UserRow:
    """Rol berish — faqat admin.

    O'zining rolini hech kim o'zgartira olmaydi: aks holda yagona admin
    o'zini tushirib yuborsa, panelga hech kim kira olmay qoladi.
    """
    user = await _target(session, user_id, me)
    user.role = payload.role
    await session.commit()

    count = await session.scalar(
        select(func.count())
        .select_from(Listing)
        .where(Listing.owner_id == user.id)
    )
    return _row(user, count or 0)


@router.patch("/users/{user_id}/block", response_model=UserRow)
async def set_blocked(
    user_id: int, payload: BlockIn, session: Session, me: Admin
) -> UserRow:
    """Bloklangan hisob ilovaga kira olmaydi — token ham ishlamay qoladi."""
    user = await _target(session, user_id, me)
    if payload.blocked and user.role in STAFF_ROLES:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            "Avval rolni oddiy foydalanuvchiga tushiring",
        )
    user.is_blocked = payload.blocked
    await session.commit()

    count = await session.scalar(
        select(func.count())
        .select_from(Listing)
        .where(Listing.owner_id == user.id)
    )
    return _row(user, count or 0)


# ---------------------------------------------------------------------------
# Push xabar
# ---------------------------------------------------------------------------


@router.post("/push", response_model=PushOut)
async def send_push(payload: PushIn, session: Session, _: Admin) -> PushOut:
    """Adminkadan xabar yuborish.

    Xabar ikki joyga tushadi: ilovadagi bildirishnomalar ro'yxatiga (bazadagi
    yozuv) va qurilma ekraniga (push). Ilovani o'chirib qo'ygan yoki push'ga
    ruxsat bermagan foydalanuvchi ham keyin ochganda xabarni ko'radi — shuning
    uchun yozuv har doim yoziladi.
    """
    title = payload.title.strip()
    body = payload.body.strip()

    if payload.user_id is not None:
        target = await session.get(User, payload.user_id)
        if target is None:
            raise HTTPException(
                status.HTTP_404_NOT_FOUND, "Foydalanuvchi topilmadi"
            )
        user_ids = [target.id]
    else:
        user_ids = list(
            await session.scalars(select(User.id).where(User.is_blocked.is_(False)))
        )

    for user_id in user_ids:
        session.add(
            Notification(
                user_id=user_id,
                kind=NotificationKind.announcement,
                title=title,
                body=body,
            )
        )
    await session.commit()

    # Push commit'dan keyin — tarmoq so'rovi tranzaksiyani ushlab turmasin
    if payload.user_id is not None:
        devices = await notify.to_user(
            session, payload.user_id, title=title, body=body
        )
    else:
        devices = await notify.to_all(session, title=title, body=body)

    return PushOut(users=len(user_ids), devices=devices)
