"""Rasmlarni saqlash.

Ikkita variant bor, `.env` dagi `STORAGE_BACKEND` bilan tanlanadi:

  local     — diskda, MEDIA_DIR papkasida (ishlab chiqish uchun)
  supabase  — Supabase Storage (serverda)

Rasm ikkalasida ham bir xil qayta ishlanadi: EXIF burilishi to'g'rilanadi,
1600px gacha kichraytiriladi, JPEG qilib siqiladi va alohida thumbnail
yasaladi. Faqat qayerga yozilishi farq qiladi.
"""

import io
import secrets
from pathlib import Path
from typing import Protocol

import httpx
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


class StorageError(RuntimeError):
    pass


class Storage(Protocol):
    async def save(self, name: str, data: bytes) -> None: ...
    async def delete(self, name: str) -> None: ...
    def url(self, name: str) -> str: ...


class LocalStorage:
    """Diskda. Serverda ishlatilmaydi — Render'da disk vaqtinchalik."""

    def _dir(self) -> Path:
        settings.media_dir.mkdir(parents=True, exist_ok=True)
        return settings.media_dir

    async def save(self, name: str, data: bytes) -> None:
        (self._dir() / name).write_bytes(data)

    async def delete(self, name: str) -> None:
        path = self._dir() / name
        if path.exists():
            path.unlink()

    def url(self, name: str) -> str:
        return f"{settings.media_url}/{name}"


class SupabaseStorage:
    """Supabase Storage. Bucket ochiq (public) bo'lishi kerak — rasmlar
    to'g'ridan-to'g'ri ilovaga beriladi, imzolangan havola shart emas."""

    def __init__(self) -> None:
        if not settings.supabase_url or not settings.supabase_service_key:
            raise StorageError(
                "SUPABASE_URL va SUPABASE_SERVICE_KEY .env da yo'q"
            )
        self._base = settings.supabase_url.rstrip("/")
        self._bucket = settings.supabase_bucket

        key = settings.supabase_service_key
        # Supabase'da ikki xil kalit formati bor:
        #   eyJ...        — eski service_role (JWT), Bearer sifatida yuboriladi
        #   sb_secret_... — yangi format, faqat apikey sarlavhasida ishlaydi
        #                   (Bearer bilan "Invalid Compact JWS" deydi)
        self._headers = {"apikey": key}
        if key.startswith("eyJ"):
            self._headers["Authorization"] = f"Bearer {key}"

    async def save(self, name: str, data: bytes) -> None:
        async with httpx.AsyncClient(timeout=30) as client:
            resp = await client.post(
                f"{self._base}/storage/v1/object/{self._bucket}/{name}",
                headers={
                    **self._headers,
                    "Content-Type": "image/jpeg",
                    "x-upsert": "true",
                },
                content=data,
            )
        if resp.status_code not in (200, 201):
            raise StorageError(f"Yuklab boʻlmadi: {resp.status_code} {resp.text}")

    async def delete(self, name: str) -> None:
        async with httpx.AsyncClient(timeout=20) as client:
            await client.delete(
                f"{self._base}/storage/v1/object/{self._bucket}/{name}",
                headers=self._headers,
            )

    def url(self, name: str) -> str:
        return f"{self._base}/storage/v1/object/public/{self._bucket}/{name}"


def _make_storage() -> Storage:
    if settings.storage_backend == "supabase":
        return SupabaseStorage()
    return LocalStorage()


storage: Storage = _make_storage()


def _prepare(raw: bytes) -> tuple[bytes, bytes, int, int]:
    """Rasmni tekshirib, siqib beradi: (asosiy, thumbnail, eni, boʻyi)."""
    if len(raw) > settings.max_photo_bytes:
        raise ImageTooLarge(f"Rasm {settings.max_photo_mb} MB dan katta")

    try:
        probe = Image.open(io.BytesIO(raw))
        probe.verify()
        img = Image.open(io.BytesIO(raw))
    except Exception as exc:  # noqa: BLE001 — har qanday buzuq fayl
        raise NotAnImage("Fayl rasm emas yoki buzilgan") from exc

    # Telefonda olingan surat aylangan bo'lishi mumkin
    img = ImageOps.exif_transpose(img).convert("RGB")
    img.thumbnail((MAX_SIDE, MAX_SIDE), Image.LANCZOS)

    main = io.BytesIO()
    img.save(main, "JPEG", quality=JPEG_QUALITY, optimize=True)

    thumb_img = img.copy()
    thumb_img.thumbnail((THUMB_SIDE, THUMB_SIDE), Image.LANCZOS)
    thumb = io.BytesIO()
    thumb_img.save(thumb, "JPEG", quality=JPEG_QUALITY, optimize=True)

    return main.getvalue(), thumb.getvalue(), img.width, img.height


async def save_photo(raw: bytes) -> tuple[str, int, int]:
    """Rasmni siqib saqlaydi. (fayl nomi, eni, boʻyi) qaytaradi."""
    main, thumb, width, height = _prepare(raw)
    name = f"{secrets.token_hex(12)}.jpg"

    await storage.save(name, main)
    await storage.save(f"t_{name}", thumb)

    return name, width, height


async def delete_photo(filename: str) -> None:
    await storage.delete(filename)
    await storage.delete(f"t_{filename}")


def photo_url(filename: str, thumb: bool = False) -> str:
    return storage.url(f"t_{filename}" if thumb else filename)
