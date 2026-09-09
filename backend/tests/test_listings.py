from httpx import AsyncClient

from tests.conftest import API, login, make_moderator, png_bytes

SELLER = "+998901112233"
BUYER = "+998935556677"


async def upload_photo(client: AsyncClient, headers: dict) -> int:
    resp = await client.post(
        f"{API}/photos",
        headers=headers,
        files={"file": ("rasm.jpg", png_bytes(), "image/jpeg")},
    )
    assert resp.status_code == 201, resp.text
    return resp.json()["id"]


async def create_listing(client: AsyncClient, headers: dict, **over) -> dict:
    photo_id = await upload_photo(client, headers)
    payload = {
        "title": "Yumshoq burchak divan",
        "description": "2 yil ishlatilgan, toza holatda.",
        "price": 3_200_000,
        "category_id": "furniture",
        "district": "Oltiariq",
        "photo_ids": [photo_id],
        "specs": [{"label": "Oʻlchami", "value": "280 × 180 sm"}],
    } | over
    resp = await client.post(f"{API}/listings", headers=headers, json=payload)
    assert resp.status_code == 201, resp.text
    return resp.json()


async def publish(client: AsyncClient, **over) -> int:
    """E'lon yaratib, moderatsiyadan o'tkazadi."""
    seller = await login(client, SELLER)
    listing = await create_listing(client, seller, **over)

    await make_moderator(SELLER)
    resp = await client.post(
        f"{API}/moderation/listings/{listing['id']}/approve", headers=seller
    )
    assert resp.status_code == 200
    return listing["id"]


async def test_yangi_elon_moderatsiyaga_tushadi(client: AsyncClient):
    headers = await login(client, SELLER)
    listing = await create_listing(client, headers)

    assert listing["status"] == "moderation"

    # Lentada hali ko'rinmaydi
    resp = await client.get(f"{API}/listings")
    assert resp.json()["total"] == 0


async def test_rasmsiz_elon_qabul_qilinmaydi(client: AsyncClient):
    headers = await login(client, SELLER)
    resp = await client.post(
        f"{API}/listings",
        headers=headers,
        json={
            "title": "Rasmsiz eʼlon",
            "price": 100000,
            "category_id": "phones",
            "district": "Quva",
            "photo_ids": [],
        },
    )
    assert resp.status_code == 422


async def test_notogri_kategoriya_rad_etiladi(client: AsyncClient):
    headers = await login(client, SELLER)
    photo_id = await upload_photo(client, headers)
    resp = await client.post(
        f"{API}/listings",
        headers=headers,
        json={
            "title": "Sinov",
            "price": 1000,
            "category_id": "kosmik-kemalar",
            "district": "Quva",
            "photo_ids": [photo_id],
        },
    )
    assert resp.status_code == 422


async def test_tasdiqlangan_elon_lentada_chiqadi(client: AsyncClient):
    listing_id = await publish(client)

    resp = await client.get(f"{API}/listings")
    body = resp.json()
    assert body["total"] == 1
    assert body["items"][0]["id"] == listing_id
    assert body["items"][0]["photo"]


async def test_qidiruv_va_filtrlar(client: AsyncClient):
    await publish(client)
    await publish(
        client,
        title="iPhone 13 128GB",
        category_id="phones",
        district="Margʻilon",
        price=4_500_000,
    )

    assert (await client.get(f"{API}/listings", params={"q": "divan"})).json()[
        "total"
    ] == 1
    assert (
        await client.get(f"{API}/listings", params={"category_id": "phones"})
    ).json()["total"] == 1
    assert (
        await client.get(f"{API}/listings", params={"district": "Oltiariq"})
    ).json()["total"] == 1
    assert (
        await client.get(f"{API}/listings", params={"price_max": 4_000_000})
    ).json()["total"] == 1


async def test_arzonidan_saralash(client: AsyncClient):
    await publish(client, title="Qimmat", price=9_000_000)
    await publish(client, title="Arzon", price=100_000)

    items = (
        await client.get(f"{API}/listings", params={"sort": "cheap"})
    ).json()["items"]
    assert [i["title"] for i in items] == ["Arzon", "Qimmat"]


async def test_kelishiladi_narx_filtriga_tushmaydi(client: AsyncClient):
    await publish(client, title="Yuk tashish", price=0, category_id="services")

    # Narx oralig'i so'ralganda narxi noma'lum e'lon chiqmasligi kerak
    body = (
        await client.get(f"{API}/listings", params={"price_max": 5_000_000})
    ).json()
    assert body["total"] == 0


async def test_telefon_faqat_alohida_sorovda_beriladi(client: AsyncClient):
    listing_id = await publish(client)

    detail = (await client.get(f"{API}/listings/{listing_id}")).json()
    assert "phone" not in detail["seller"]
    assert detail["seller"]["phone_verified"] is True

    resp = await client.post(f"{API}/listings/{listing_id}/reveal-phone")
    assert resp.status_code == 200
    assert resp.json()["phone"] == SELLER


async def test_korishlar_sanaladi(client: AsyncClient):
    listing_id = await publish(client)

    await client.get(f"{API}/listings/{listing_id}")
    detail = (await client.get(f"{API}/listings/{listing_id}")).json()
    assert detail["views"] >= 1


async def test_moderatsiyadagi_elon_begonaga_korinmaydi(client: AsyncClient):
    seller = await login(client, SELLER)
    listing = await create_listing(client, seller)

    # Egasi ko'radi
    assert (
        await client.get(f"{API}/listings/{listing['id']}", headers=seller)
    ).status_code == 200
    # Begona ko'rmaydi
    assert (
        await client.get(f"{API}/listings/{listing['id']}")
    ).status_code == 404


async def test_rad_etilganda_sabab_yoziladi(client: AsyncClient):
    seller = await login(client, SELLER)
    listing = await create_listing(client, seller)
    await make_moderator(SELLER)

    resp = await client.post(
        f"{API}/moderation/listings/{listing['id']}/reject",
        headers=seller,
        json={"reason": "Rasm sifati past"},
    )
    assert resp.status_code == 200

    detail = (
        await client.get(f"{API}/listings/{listing['id']}", headers=seller)
    ).json()
    assert detail["status"] == "rejected"
    assert detail["reject_reason"] == "Rasm sifati past"

    # Egasiga bildirishnoma keldi
    notes = (await client.get(f"{API}/notifications", headers=seller)).json()
    assert notes["items"][0]["kind"] == "rejected"


async def test_moderator_boshqa_odam_bola_olmaydi(client: AsyncClient):
    buyer = await login(client, BUYER)
    assert (await client.get(f"{API}/moderation/queue", headers=buyer)).status_code == 403
