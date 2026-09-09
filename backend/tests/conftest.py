import os

# Sozlamalar import qilinmasdan oldin qo'yilishi shart
os.environ["DATABASE_URL"] = (
    "postgresql+asyncpg://oson:oson@localhost:5432/oson_top_test"
)
os.environ["ALLOW_DEV_LOGIN"] = "true"
os.environ["MEDIA_DIR"] = "./.test-media"

import shutil
from pathlib import Path

import pytest
from httpx import ASGITransport, AsyncClient

from app.config import settings
from app.db import SessionLocal, engine
from app.main import app
from app.models import Base, User, UserRole

API = "/api/v1"


@pytest.fixture(autouse=True)
async def _clean_db():
    """Har test toza bazadan boshlanadi.

    Har testda o'z event loop'i bo'lgani uchun ulanishlar hovuzi
    testdan keyin yopiladi — aks holda "Event loop is closed" chiqadi.
    """
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
    yield
    await engine.dispose()
    shutil.rmtree(Path(settings.media_dir), ignore_errors=True)


@pytest.fixture
async def client():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c


async def login(client: AsyncClient, phone: str = "+998901112233") -> dict[str, str]:
    resp = await client.post(f"{API}/auth/dev-login", json={"phone": phone})
    assert resp.status_code == 200, resp.text
    return {"Authorization": f"Bearer {resp.json()['access_token']}"}


async def make_moderator(phone: str) -> None:
    from sqlalchemy import select, update

    async with SessionLocal() as session:
        await session.execute(
            update(User).where(User.phone == phone).values(role=UserRole.moderator)
        )
        await session.commit()
        assert await session.scalar(select(User).where(User.phone == phone))


def png_bytes() -> bytes:
    import io

    from PIL import Image

    buf = io.BytesIO()
    Image.new("RGB", (800, 600), (200, 220, 210)).save(buf, "JPEG")
    return buf.getvalue()
