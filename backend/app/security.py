import hashlib
import hmac
import secrets
from datetime import UTC, datetime, timedelta
from typing import Literal

import jwt

from .config import settings

TokenType = Literal["access", "refresh"]


def create_token(user_id: int, kind: TokenType = "access") -> str:
    now = datetime.now(UTC)
    lifetime = (
        timedelta(minutes=settings.access_token_minutes)
        if kind == "access"
        else timedelta(days=settings.refresh_token_days)
    )
    payload = {
        "sub": str(user_id),
        "typ": kind,
        "iat": now,
        "exp": now + lifetime,
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256")


def decode_token(token: str, expect: TokenType = "access") -> int | None:
    """Token yaroqli bo'lsa user id qaytaradi, bo'lmasa None."""
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=["HS256"])
    except jwt.PyJWTError:
        return None
    if payload.get("typ") != expect:
        return None
    try:
        return int(payload["sub"])
    except (KeyError, TypeError, ValueError):
        return None


def generate_code() -> str:
    """6 xonali kirish kodi."""
    return f"{secrets.randbelow(1_000_000):06d}"


def hash_code(phone: str, code: str) -> str:
    """Kod ochiq saqlanmaydi. Telefon ham aralashtiriladi — bir bazadagi
    kodni boshqa raqamga ishlatib bo'lmaydi."""
    msg = f"{phone}:{code}".encode()
    return hmac.new(settings.jwt_secret.encode(), msg, hashlib.sha256).hexdigest()


def verify_code(phone: str, code: str, code_hash: str) -> bool:
    return hmac.compare_digest(hash_code(phone, code), code_hash)


def normalize_phone(raw: str) -> str | None:
    """'+998 90 123 45 67', '998901234567', '901234567' → '+998901234567'.

    Faqat O'zbekiston raqamlari qabul qilinadi.
    """
    digits = "".join(ch for ch in raw if ch.isdigit())
    if len(digits) == 9:
        digits = "998" + digits
    if len(digits) != 12 or not digits.startswith("998"):
        return None
    return "+" + digits
