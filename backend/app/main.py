import asyncio
import logging
from contextlib import asynccontextmanager, suppress

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from .api import (
    auth,
    favorites,
    listings,
    me,
    moderation,
    notifications,
    photos,
    reference,
)
from .config import settings
from .services import telegram

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s — %(message)s",
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings.media_dir.mkdir(parents=True, exist_ok=True)

    poller: asyncio.Task | None = None
    if settings.telegram_bot_token:
        if settings.telegram_webhook_url:
            await telegram.setup_webhook()
        else:
            # Domen yo'q — long polling. Ishlab chiqishda shu ishlaydi.
            poller = asyncio.create_task(telegram.poll_forever())

    yield

    if poller is not None:
        poller.cancel()
        with suppress(asyncio.CancelledError):
            await poller


app = FastAPI(
    title="Oson Top API",
    description="Fargʻona viloyati uchun eʼlonlar ilovasining backend'i",
    version="0.1.0",
    lifespan=lifespan,
)

# Mobil ilova uchun origin cheklovi ma'nosiz; moderatsiya paneli
# uchun keyin aniq domen qo'yiladi.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount(
    settings.media_url,
    StaticFiles(directory=settings.media_dir, check_dir=False),
    name="media",
)

for router in (
    auth.router,
    reference.router,
    listings.router,
    photos.router,
    favorites.router,
    notifications.router,
    me.router,
    moderation.router,
):
    app.include_router(router, prefix="/api/v1")


@app.get("/health", tags=["service"])
async def health() -> dict[str, str]:
    return {"status": "ok"}
