import secrets
from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Header, HTTPException, Request, status
from sqlalchemy import select

from ..config import settings
from ..deps import Session
from ..models import LoginToken, User
from ..schemas.auth import DevLoginIn, LoginStart, LoginStatus, RefreshIn, Tokens
from ..security import create_token, decode_token, normalize_phone
from ..services import telegram

router = APIRouter(prefix="/auth", tags=["auth"])

TOKEN_TTL = timedelta(minutes=10)


@router.post("/telegram/start", response_model=LoginStart)
async def telegram_start(session: Session) -> LoginStart:
    """Kirishni boshlaydi. Ilova qaytgan `deep_link` ni ochadi."""
    if not settings.telegram_bot_username:
        raise HTTPException(
            status.HTTP_503_SERVICE_UNAVAILABLE,
            "Telegram bot sozlanmagan",
        )

    token = secrets.token_urlsafe(24)
    session.add(
        LoginToken(token=token, expires_at=datetime.now(UTC) + TOKEN_TTL)
    )
    await session.commit()

    return LoginStart(
        token=token,
        deep_link=telegram.deep_link(token),
        expires_in=int(TOKEN_TTL.total_seconds()),
    )


@router.get("/telegram/status", response_model=LoginStatus)
async def telegram_status(token: str, session: Session) -> LoginStatus:
    """Ilova shu endpointni bir necha soniyada bir marta so'raydi.

    Foydalanuvchi botda raqamni ulashgach — tokenlar qaytadi.
    """
    record = await session.scalar(
        select(LoginToken).where(LoginToken.token == token)
    )
    if record is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Token topilmadi")

    if record.expires_at < datetime.now(UTC):
        return LoginStatus(status="expired")
    if record.consumed:
        return LoginStatus(status="used")
    if record.user_id is None:
        return LoginStatus(status="pending")

    # Token bir marta ishlaydi
    record.consumed = True
    await session.commit()

    return LoginStatus(
        status="ready",
        access_token=create_token(record.user_id, "access"),
        refresh_token=create_token(record.user_id, "refresh"),
    )


@router.post("/telegram/webhook", include_in_schema=False)
async def telegram_webhook(
    request: Request,
    x_telegram_bot_api_secret_token: str | None = Header(None),
) -> dict[str, bool]:
    """Ishlab chiqarishda Telegram yangilanishlarni shu yerga yuboradi.
    Ishlab chiqishda long polling ishlaydi va bu chaqirilmaydi."""
    if settings.telegram_webhook_secret and (
        x_telegram_bot_api_secret_token != settings.telegram_webhook_secret
    ):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Sirli kalit notoʻgʻri")

    await telegram.handle_update(await request.json())
    return {"ok": True}


@router.post("/dev-login", response_model=Tokens)
async def dev_login(payload: DevLoginIn, session: Session) -> Tokens:
    """Telegramsiz kirish — faqat ishlab chiqish uchun.
    Ishlab chiqarishda ALLOW_DEV_LOGIN=false bo'lishi shart."""
    if not settings.allow_dev_login:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Topilmadi")

    phone = normalize_phone(payload.phone)
    if phone is None:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, "Raqam notoʻgʻri")

    user = await session.scalar(select(User).where(User.phone == phone))
    if user is None:
        user = User(phone=phone, phone_verified=True)
        session.add(user)
        await session.commit()
        await session.refresh(user)

    return Tokens(
        access_token=create_token(user.id, "access"),
        refresh_token=create_token(user.id, "refresh"),
    )


@router.post("/refresh", response_model=Tokens)
async def refresh(payload: RefreshIn, session: Session) -> Tokens:
    user_id = decode_token(payload.refresh_token, expect="refresh")
    if user_id is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Token yaroqsiz")

    user = await session.get(User, user_id)
    if user is None or user.is_blocked:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Token yaroqsiz")

    user.last_seen_at = datetime.now(UTC)
    await session.commit()

    return Tokens(
        access_token=create_token(user.id, "access"),
        refresh_token=create_token(user.id, "refresh"),
    )
