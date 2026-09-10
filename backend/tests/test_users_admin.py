"""Panel foydalanuvchilar bo'limi: ko'rish, rol berish, bloklash."""

import pytest

from app.config import settings
from app.models import UserRole
from tests.conftest import API, login, make_admin, make_moderator

OWNER = "+998901112233"
OTHER = "+998907776655"


@pytest.fixture
async def admin(client):
    headers = await login(client, OWNER)
    await make_admin(OWNER)
    return headers


async def test_oddiy_foydalanuvchi_royxatni_kormaydi(client):
    headers = await login(client, OWNER)
    resp = await client.get(f"{API}/moderation/users", headers=headers)
    assert resp.status_code == 403


async def test_moderator_royxatni_koradi(client):
    await login(client, OTHER)
    headers = await login(client, OWNER)
    await make_moderator(OWNER)

    resp = await client.get(f"{API}/moderation/users", headers=headers)
    assert resp.status_code == 200
    body = resp.json()
    assert body["total"] == 2
    phones = {row["phone"] for row in body["items"]}
    assert phones == {OWNER, OTHER}


async def test_moderator_rol_bera_olmaydi(client):
    other = await login(client, OTHER)
    del other
    headers = await login(client, OWNER)
    await make_moderator(OWNER)

    target = await _id_of(client, headers, OTHER)
    resp = await client.patch(
        f"{API}/moderation/users/{target}/role",
        json={"role": "moderator"},
        headers=headers,
    )
    assert resp.status_code == 403


async def test_admin_moderator_qiladi(client, admin):
    await login(client, OTHER)
    target = await _id_of(client, admin, OTHER)

    resp = await client.patch(
        f"{API}/moderation/users/{target}/role",
        json={"role": "moderator"},
        headers=admin,
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["role"] == "moderator"

    # Endi u panelga kira oladi
    theirs = await login(client, OTHER)
    assert (await client.get(f"{API}/moderation/counts", headers=theirs)).status_code == 200


async def test_oz_rolini_ozgartira_olmaydi(client, admin):
    mine = await _id_of(client, admin, OWNER)
    resp = await client.patch(
        f"{API}/moderation/users/{mine}/role",
        json={"role": "user"},
        headers=admin,
    )
    assert resp.status_code == 400


async def test_bloklangan_hisob_kira_olmaydi(client, admin):
    theirs = await login(client, OTHER)
    target = await _id_of(client, admin, OTHER)

    resp = await client.patch(
        f"{API}/moderation/users/{target}/block",
        json={"blocked": True},
        headers=admin,
    )
    assert resp.status_code == 200
    assert resp.json()["is_blocked"] is True

    # Eski token ham ishlamay qoladi
    assert (await client.get(f"{API}/me", headers=theirs)).status_code == 401


async def test_moderatorni_avval_tushirish_kerak(client, admin):
    await login(client, OTHER)
    await make_moderator(OTHER)
    target = await _id_of(client, admin, OTHER)

    resp = await client.patch(
        f"{API}/moderation/users/{target}/block",
        json={"blocked": True},
        headers=admin,
    )
    assert resp.status_code == 400


async def test_qidiruv_raqam_boyicha(client, admin):
    await login(client, OTHER)
    resp = await client.get(
        f"{API}/moderation/users", params={"q": "7776655"}, headers=admin
    )
    assert resp.status_code == 200
    items = resp.json()["items"]
    assert len(items) == 1
    assert items[0]["phone"] == OTHER


@pytest.mark.parametrize(
    "written",
    [
        "+998901112233",
        "998901112233",
        "901112233",
        "+998 90 111 22 33",
        "+998907776655, +998901112233",
    ],
)
async def test_admin_phones_kirishda_huquq_beradi(client, monkeypatch, written):
    """.env dagi raqam bilan kirgan hisob o'zi admin bo'lib qoladi.

    Raqam qanday yozilganidan qat'i nazar ishlashi kerak.
    """
    monkeypatch.setattr(settings, "admin_phones", written)

    headers = await login(client, OWNER)
    resp = await client.get(f"{API}/me", headers=headers)
    assert resp.status_code == 200
    assert resp.json()["user"]["role"] == UserRole.admin


async def test_admin_phones_bosh_bolsa_hech_kimga_huquq_yoq(client, monkeypatch):
    monkeypatch.setattr(settings, "admin_phones", "")

    headers = await login(client, OWNER)
    resp = await client.get(f"{API}/me", headers=headers)
    assert resp.json()["user"]["role"] == UserRole.user


async def _id_of(client, headers, phone: str) -> int:
    page = await client.get(
        f"{API}/moderation/users", params={"q": phone}, headers=headers
    )
    assert page.status_code == 200, page.text
    return page.json()["items"][0]["id"]
