"""Bildirishnoma yuborish.

Bildirishnoma ikki joyda ko'rinadi: ilovadagi ro'yxatda (bazadagi yozuv) va
qurilma ekranida (push). Shu yerda ikkalasi birga yuritiladi — biri ikkinchisiz
qolmasin.

Push commit'dan keyin yuboriladi: tarmoq so'rovi tranzaksiya ichida turib
qolmasligi kerak.
"""

import logging

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models import DeviceToken
from . import push

log = logging.getLogger("oson.notify")


async def _send(
    session: AsyncSession,
    tokens: list[str],
    *,
    title: str,
    body: str,
    data: dict[str, str] | None = None,
) -> int:
    """Yuboradi va yaroqsiz tokenlarni bazadan tozalaydi.

    Qaytaradi: nechta qurilmaga yuborishga urinildi.
    """
    if not tokens:
        return 0

    dead = await push.send(tokens, title=title, body=body, data=data)
    if dead:
        await session.execute(
            delete(DeviceToken).where(DeviceToken.token.in_(dead))
        )
        await session.commit()
        log.info("%d ta yaroqsiz token oʻchirildi", len(dead))
    return len(tokens)


async def to_user(
    session: AsyncSession,
    user_id: int,
    *,
    title: str,
    body: str,
    data: dict[str, str] | None = None,
) -> int:
    tokens = list(
        await session.scalars(
            select(DeviceToken.token).where(DeviceToken.user_id == user_id)
        )
    )
    return await _send(session, tokens, title=title, body=body, data=data)


async def to_all(
    session: AsyncSession,
    *,
    title: str,
    body: str,
    data: dict[str, str] | None = None,
) -> int:
    tokens = list(await session.scalars(select(DeviceToken.token)))
    return await _send(session, tokens, title=title, body=body, data=data)
