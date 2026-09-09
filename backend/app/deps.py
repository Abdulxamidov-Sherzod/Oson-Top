from typing import Annotated

from fastapi import Depends, Header, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from .db import get_session
from .models import User, UserRole
from .security import decode_token

Session = Annotated[AsyncSession, Depends(get_session)]


async def _user_from_header(
    session: AsyncSession, authorization: str | None
) -> User | None:
    if not authorization or not authorization.lower().startswith("bearer "):
        return None
    user_id = decode_token(authorization[7:], expect="access")
    if user_id is None:
        return None
    user = await session.get(User, user_id)
    if user is None or user.is_blocked:
        return None
    return user


async def current_user(
    session: Session,
    authorization: Annotated[str | None, Header()] = None,
) -> User:
    """Kirish majburiy bo'lgan endpointlar uchun."""
    user = await _user_from_header(session, authorization)
    if user is None:
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED,
            "Kirish kerak",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user


async def optional_user(
    session: Session,
    authorization: Annotated[str | None, Header()] = None,
) -> User | None:
    """Lenta va e'lon sahifasi kirmasdan ham ochiladi — lekin kirgan
    bo'lsa "saqlangan" belgisi to'g'ri ko'rsatiladi."""
    return await _user_from_header(session, authorization)


async def current_moderator(
    user: Annotated[User, Depends(current_user)],
) -> User:
    if user.role not in (UserRole.moderator, UserRole.admin):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Ruxsat yo'q")
    return user


CurrentUser = Annotated[User, Depends(current_user)]
OptionalUser = Annotated[User | None, Depends(optional_user)]
Moderator = Annotated[User, Depends(current_moderator)]
