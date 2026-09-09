from httpx import AsyncClient

from tests.conftest import API, login


async def test_dev_login_yangi_hisob_yaratadi(client: AsyncClient):
    headers = await login(client, "+998901112233")

    resp = await client.get(f"{API}/me", headers=headers)
    assert resp.status_code == 200
    assert resp.json()["user"]["phone"] == "+998901112233"


async def test_notogri_raqam_rad_etiladi(client: AsyncClient):
    resp = await client.post(f"{API}/auth/dev-login", json={"phone": "12345"})
    assert resp.status_code == 422


async def test_kirmasdan_profil_ochilmaydi(client: AsyncClient):
    assert (await client.get(f"{API}/me")).status_code == 401


async def test_refresh_yangi_token_beradi(client: AsyncClient):
    resp = await client.post(
        f"{API}/auth/dev-login", json={"phone": "+998901112233"}
    )
    refresh = resp.json()["refresh_token"]

    resp = await client.post(f"{API}/auth/refresh", json={"refresh_token": refresh})
    assert resp.status_code == 200
    assert resp.json()["access_token"]


async def test_access_token_refresh_orniga_ishlamaydi(client: AsyncClient):
    resp = await client.post(
        f"{API}/auth/dev-login", json={"phone": "+998901112233"}
    )
    access = resp.json()["access_token"]

    resp = await client.post(f"{API}/auth/refresh", json={"refresh_token": access})
    assert resp.status_code == 401


async def test_telegram_start_havola_beradi(client: AsyncClient):
    resp = await client.post(f"{API}/auth/telegram/start")
    assert resp.status_code == 200
    body = resp.json()
    assert body["deep_link"].startswith("https://t.me/")
    assert body["token"] in body["deep_link"]

    # Hali botda tugatilmagan
    resp = await client.get(f"{API}/auth/telegram/status", params={"token": body["token"]})
    assert resp.json()["status"] == "pending"
