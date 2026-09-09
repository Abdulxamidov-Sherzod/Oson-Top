"""Rasmlarni saqlash.

Hozircha diskda — MEDIA_DIR papkasida. Serverga chiqqanda shu modulni
S3 mos xizmatga (Backblaze B2, Cloudflare R2) o'tkazish yetarli,
qolgan kod tegilmaydi.
"""

import io
import secrets
from pathlib import Path

from PIL import Image, ImageOps

from ..config import settings

# Telefon ekraniga yetarli, trafikni tejaydi
MAX_SIDE = 1600
THUMB_SIDE = 480
JPEG_QUALITY = 82


class ImageTooLarge(ValueError):
    pass


class NotAnImage(ValueError):
    pass


def _media_dir() -> Path:
    settings.media_dir.mkdir(parents=True, exist_ok=True)
    return settings.media_dir


def save_photo(raw: bytes) -> tuple[str, int, int]:
    """Rasmni siqib saqlaydi. (fayl nomi, eni, bo'yi) qaytaradi."""
    if len(raw) > settings.max_photo_bytes:
        raise ImageTooLarge(f"Rasm {settings.max_photo_mb} MB dan katta")

    try:
        img = Image.open(io.BytesIO(raw))
        img.verify()
        img = Image.open(io.BytesIO(raw))
    except Exception as exc:
        raise NotAnImage("Fayl rasm emas yoki buzilgan") from exc

    # Telefonda olingan surat aylangan bo'lishi mumkin
    img = ImageOps.exif_transpose(img)
    img = img.convert("RGB")
    img.thumbnail((MAX_SIDE, MAX_SIDE), Image.LANCZOS)

    name = f"{secrets.token_hex(12)}.jpg"
    path = _media_dir() / name
    img.save(path, "JPEG", quality=JPEG_QUALITY, optimize=True)

    thumb = img.copy()
    thumb.thumbnail((THUMB_SIDE, THUMB_SIDE), Image.LANCZOS)
    thumb.save(_media_dir() / f"t_{name}", "JPEG", quality=JPEG_QUALITY, optimize=True)

    return name, img.width, img.height


def delete_photo(filename: str) -> None:
    for candidate in (filename, f"t_{filename}"):
        path = _media_dir() / candidate
        if path.exists():
            path.unlink()


def photo_url(filename: str, thumb: bool = False) -> str:
    prefix = "t_" if thumb else ""
    return f"{settings.media_url}/{prefix}{filename}"
