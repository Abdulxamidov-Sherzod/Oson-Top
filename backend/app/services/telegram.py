"""Telegram bot — kirish shu orqali.

Oqim:
  1. Ilova token so'raydi, `t.me/<bot>?start=<token>` havolasini oladi
  2. Foydalanuvchi havolani ochadi, botda "Start" bosadi
  3. Bot "Raqamni ulashish" tugmasini ko'rsatadi
  4. Foydalanuvchi bosadi — Telegram botga TASDIQLANGAN raqamni yuboradi
  5. Backend hisobni yaratadi va tokenni unga bog'laydi
  6. Ilova holatni so'rab turadi va JWT oladi

Raqam Telegram'dan kelgani uchun uni alohida tasdiqlash shart emas —
shuning uchun SMS ham, uning puli ham kerak emas.
"""

import asyncio
import logging
from datetime import UTC, datetime

import httpx
from sqlalchemy import select

from ..config import settings
from ..db import SessionLocal
from ..models import LoginToken, User

log = logging.getLogger("oson.telegram")

API = "https://api.telegram.org"

GREETING = (
    "Assalomu alaykum!\n\n"
    "Oson Top ilovasiga kirish uchun telefon raqamingizni ulashing. "
    "Raqam eʼlonlaringizda xaridorlar bogʻlanishi uchun kerak — "
    "u yopiq turadi va faqat «Raqamni koʻrsatish» bosilganda ochiladi."
)

DONE = (
    "Tayyor! Ilovaga qayting — kirdingiz.\n\n"
    "Eʼlon berish uchun ilovadagi yashil «+» tugmasini bosing."
)

NO_TOKEN = (
    "Kirish uchun Oson Top ilovasidan «Telegram orqali kirish» tugmasini bosing."
)


class TelegramError(RuntimeError):
    pass


def _url(method: str) -> str:
    return f"{API}/bot{settings.telegram_bot_token}/{method}"


async def call(method: str, **payload) -> dict:
    if not settings.telegram_bot_token:
        raise TelegramError("TELEGRAM_BOT_TOKEN .env da yo'q")
    async with httpx.AsyncClient(timeout=65) as client:
        resp = await client.post(_url(method), json=payload)
    data = resp.json()
    if not data.get("ok"):
        raise TelegramError(f"{method}: {data}")
    return data["result"]


def deep_link(token: str) -> str:
    return f"https://t.me/{settings.telegram_bot_username}?start={token}"


async def _ask_for_contact(chat_id: int) -> None:
    await call(
        "sendMessage",
        chat_id=chat_id,
        text=GREETING,
        reply_markup={
            "keyboard": [
                [{"text": "📱 Raqamni ulashish", "request_contact": True}]
            ],
            "resize_keyboard": True,
            "one_time_keyboard": True,
        },
    )


async def _say_done(chat_id: int) -> None:
    await call(
        "sendMessage",
        chat_id=chat_id,
        text=DONE,
        reply_markup={"remove_keyboard": True},
    )


def _normalize(phone: str) -> str:
    digits = "".join(ch for ch in phone if ch.isdigit())
    return "+" + digits


async def handle_update(update: dict) -> None:
    """Bitta Telegram yangilanishini qayta ishlaydi.

    Webhook ham, long polling ham shu funksiyani chaqiradi.
    """
    message = update.get("message")
    if not message:
        return

    chat_id = message["chat"]["id"]
    from_user = message.get("from", {})
    tg_id = from_user.get("id")
    text = message.get("text", "")
    contact = message.get("contact")

    async with SessionLocal() as session:
        # 1-qadam: /start <token>
        if text.startswith("/start"):
            parts = text.split(maxsplit=1)
            token = parts[1].strip() if len(parts) > 1 else ""
            if not token:
                await call("sendMessage", chat_id=chat_id, text=NO_TOKEN)
                return

            record = await session.scalar(
                select(LoginToken).where(LoginToken.token == token)
            )
            if record is None or record.expires_at < datetime.now(UTC):
                await call(
                    "sendMessage",
                    chat_id=chat_id,
                    text="Havola eskirgan. Ilovadan qaytadan urinib koʻring.",
                )
                return

            # Tokenni shu Telegram hisobiga vaqtincha biriktiramiz
            _pending[tg_id] = token
            await _ask_for_contact(chat_id)
            return

        # 2-qadam: raqam ulashildi
        if contact:
            # Boshqa odamning kontaktini yuborib bo'lmaydi
            if contact.get("user_id") != tg_id:
                await call(
                    "sendMessage",
                    chat_id=chat_id,
                    text="Iltimos, oʻz raqamingizni ulashing.",
                )
                return

            token = _pending.pop(tg_id, None)
            if token is None:
                await call("sendMessage", chat_id=chat_id, text=NO_TOKEN)
                return

            record = await session.scalar(
                select(LoginToken).where(LoginToken.token == token)
            )
            if record is None or record.expires_at < datetime.now(UTC):
                await call(
                    "sendMessage",
                    chat_id=chat_id,
                    text="Havola eskirgan. Ilovadan qaytadan urinib koʻring.",
                )
                return

            phone = _normalize(contact["phone_number"])
            user = await session.scalar(
                select(User).where(User.telegram_id == tg_id)
            )
            if user is None:
                user = await session.scalar(select(User).where(User.phone == phone))

            if user is None:
                user = User(
                    telegram_id=tg_id,
                    telegram_username=from_user.get("username"),
                    phone=phone,
                    phone_verified=True,
                    name=(
                        f"{from_user.get('first_name', '')} "
                        f"{from_user.get('last_name', '')}"
                    ).strip()
                    or None,
                )
                session.add(user)
                await session.flush()
            else:
                user.telegram_id = tg_id
                user.telegram_username = from_user.get("username")
                user.phone = phone
                user.phone_verified = True

            record.user_id = user.id
            await session.commit()
            await _say_done(chat_id)


# tg_id → token. Bot bilan suhbat qisqa, shuning uchun xotirada saqlash yetarli.
_pending: dict[int, str] = {}


async def poll_forever() -> None:
    """Long polling. Webhook o'rniga — domen va sertifikat kerak emas,
    shuning uchun ishlab chiqishda qulay."""
    offset = 0
    log.info("Telegram long polling boshlandi")
    while True:
        try:
            updates = await call("getUpdates", offset=offset, timeout=50)
            for update in updates:
                offset = update["update_id"] + 1
                try:
                    await handle_update(update)
                except Exception:
                    log.exception("Yangilanishni qayta ishlashda xato")
        except asyncio.CancelledError:
            raise
        except Exception:
            log.exception("getUpdates xatosi, 5 soniyadan keyin qayta urinaman")
            await asyncio.sleep(5)


async def setup_webhook() -> None:
    await call(
        "setWebhook",
        url=settings.telegram_webhook_url,
        secret_token=settings.telegram_webhook_secret or None,
        allowed_updates=["message"],
    )
    log.info("Telegram webhook o'rnatildi: %s", settings.telegram_webhook_url)
