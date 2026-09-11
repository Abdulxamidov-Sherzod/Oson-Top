from httpx import AsyncClient

from tests.conftest import API, login
from tests.test_listings import SELLER, publish

BUYER = "+998935556677"


async def test_saqlash_va_ochirish(client: AsyncClient):
    listing_id = await publish(client)
    buyer = await login(client, BUYER)

    assert (
        await client.put(f"{API}/favorites/{listing_id}", headers=buyer)
    ).status_code == 200

    body = (await client.get(f"{API}/favorites", headers=buyer)).json()
    assert body["total"] == 1
    assert body["items"][0]["id"] == listing_id

    await client.delete(f"{API}/favorites/{listing_id}", headers=buyer)
    assert (await client.get(f"{API}/favorites", headers=buyer)).json()["total"] == 0


async def test_ikki_marta_saqlash_nusxa_yaratmaydi(client: AsyncClient):
    listing_id = await publish(client)
    buyer = await login(client, BUYER)

    await client.put(f"{API}/favorites/{listing_id}", headers=buyer)
    await client.put(f"{API}/favorites/{listing_id}", headers=buyer)

    assert (await client.get(f"{API}/favorites", headers=buyer)).json()["total"] == 1


async def test_lentada_saqlangan_belgisi(client: AsyncClient):
    listing_id = await publish(client)
    buyer = await login(client, BUYER)
    await client.put(f"{API}/favorites/{listing_id}", headers=buyer)

    # Kirgan odam uchun belgi to'g'ri
    items = (await client.get(f"{API}/listings", headers=buyer)).json()["items"]
    assert items[0]["is_favorite"] is True

    # Kirmagan odam uchun har doim false
    items = (await client.get(f"{API}/listings")).json()["items"]
    assert items[0]["is_favorite"] is False


async def test_profil_statistikasi(client: AsyncClient):
    listing_id = await publish(client)
    seller = await login(client, SELLER)

    await client.put(f"{API}/favorites/{listing_id}", headers=seller)
    await client.get(f"{API}/listings/{listing_id}")

    stats = (await client.get(f"{API}/me", headers=seller)).json()["stats"]
    assert stats["active_listings"] == 1
    assert stats["total_listings"] == 1
    assert stats["favorites"] == 1
    assert stats["total_views"] >= 1


async def test_moderatsiyadagi_elon_umumiy_songa_kiradi(client: AsyncClient):
    """«Mening e'lonlarim» ro'yxati hamma holatdagini ko'rsatadi, shuning
    uchun yonidagi son ham hammasini sanashi kerak — faqat aktivni emas."""
    from tests.test_listings import create_listing

    await publish(client)                       # 1-si tasdiqlangan
    seller = await login(client, SELLER)
    await create_listing(client, seller)        # 2-si moderatsiyada

    stats = (await client.get(f"{API}/me", headers=seller)).json()["stats"]
    assert stats["active_listings"] == 1
    assert stats["total_listings"] == 2

    page = (await client.get(f"{API}/me/listings", headers=seller)).json()
    assert page["total"] == 2


async def test_profilni_tahrirlash(client: AsyncClient):
    headers = await login(client, BUYER)

    resp = await client.patch(
        f"{API}/me",
        headers=headers,
        json={"name": "Nodira Karimova", "district": "Margʻilon"},
    )
    assert resp.status_code == 200
    assert resp.json()["name"] == "Nodira Karimova"
    assert resp.json()["district"] == "Margʻilon"

    # Boʻsh satr — tumanni oʻchirish. Ilova aynan shuni yuboradi.
    resp = await client.patch(
        f"{API}/me", headers=headers, json={"district": ""}
    )
    assert resp.status_code == 200
    assert resp.json()["district"] is None
    # Yuborilmagan maydon tegilmaydi
    assert resp.json()["name"] == "Nodira Karimova"


async def test_bildirishnomalarni_oqilgan_qilish(client: AsyncClient):
    await publish(client)
    seller = await login(client, SELLER)

    assert (
        await client.get(f"{API}/notifications/unread-count", headers=seller)
    ).json()["unread"] == 1

    await client.post(f"{API}/notifications/read-all", headers=seller)
    assert (
        await client.get(f"{API}/notifications/unread-count", headers=seller)
    ).json()["unread"] == 0


async def test_malumotnoma(client: AsyncClient):
    cats = (await client.get(f"{API}/reference/categories")).json()
    districts = (await client.get(f"{API}/reference/districts")).json()

    assert len(cats) == 10
    assert {"id": "phones", "label": "Telefonlar"} in cats
    assert "Fargʻona shahri" in districts
    assert len(districts) == 18
