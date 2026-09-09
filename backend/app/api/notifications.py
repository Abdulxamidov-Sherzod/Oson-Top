from typing import Annotated

from fastapi import APIRouter, Query
from sqlalchemy import func, select, update

from ..deps import CurrentUser, Session
from ..models import Notification
from ..schemas.common import Ok, Page
from ..schemas.notification import NotificationOut, UnreadCount

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("", response_model=Page[NotificationOut])
async def listing(
    session: Session,
    user: CurrentUser,
    limit: Annotated[int, Query(ge=1, le=50)] = 30,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> Page[NotificationOut]:
    total = await session.scalar(
        select(func.count())
        .select_from(Notification)
        .where(Notification.user_id == user.id)
    )
    rows = list(
        await session.scalars(
            select(Notification)
            .where(Notification.user_id == user.id)
            .order_by(Notification.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
    )
    return Page(
        items=[NotificationOut.model_validate(r) for r in rows],
        total=total or 0,
        limit=limit,
        offset=offset,
    )


@router.get("/unread-count", response_model=UnreadCount)
async def unread_count(session: Session, user: CurrentUser) -> UnreadCount:
    """Bosh sahifadagi qo'ng'iroqcha badge'i shu yerdan."""
    count = await session.scalar(
        select(func.count())
        .select_from(Notification)
        .where(Notification.user_id == user.id, Notification.unread.is_(True))
    )
    return UnreadCount(unread=count or 0)


@router.post("/read-all", response_model=Ok)
async def read_all(session: Session, user: CurrentUser) -> Ok:
    await session.execute(
        update(Notification)
        .where(Notification.user_id == user.id, Notification.unread.is_(True))
        .values(unread=False)
    )
    await session.commit()
    return Ok()


@router.post("/{notification_id}/read", response_model=Ok)
async def read_one(
    notification_id: int, session: Session, user: CurrentUser
) -> Ok:
    await session.execute(
        update(Notification)
        .where(Notification.id == notification_id, Notification.user_id == user.id)
        .values(unread=False)
    )
    await session.commit()
    return Ok()
