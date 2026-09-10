"""Sinov ma'lumotlari.

    python -m app.seed

Bazani tozalab, Flutter'dagi mock e'lonlarni yozadi. Rasmlar o'rniga
oddiy rangli to'rtburchaklar chiziladi — haqiqiy foto emas, lekin lenta
bo'sh ko'rinmaydi.
"""

import asyncio
import io
import random
from datetime import UTC, datetime, timedelta

from PIL import Image, ImageDraw
from sqlalchemy import delete, select

from .db import SessionLocal
from .models import (
    Favorite,
    Listing,
    ListingCondition,
    ListingPhoto,
    ListingSpec,
    ListingStatus,
    LoginToken,
    Notification,
    NotificationKind,
    User,
    UserRole,
)
from .services.storage import save_photo

# (ism, telefon)
SELLERS = [
    ("Sardor Aliyev", "+998905123467"),
    ("Jasur Qodirov", "+998931184092"),
    ("Nilufar Ahmedova", "+998912458810"),
    ("Ulugʻbek Nazarov", "+998906041977"),
    ("Muhabbat Isroilova", "+998995120744"),
    ("Dilnoza Toʻxtasinova", "+998943307105"),
]

# (sarlavha, narx, birlik, kategoriya, tuman, holat, tavsif, (lat,lng)|None)
LISTINGS = [
    (
        "iPhone 13 128GB, ideal holat, quti bilan", 4_500_000, None, "phones",
        "Fargʻona shahri", ListingCondition.used,
        (
            "Telefon 1 yil ishlatilgan, hech qanday nuqsoni yoʻq. Batareya holati 92%. "
            "Quti, original kabel va himoya gʻilofi bilan beriladi."
        ),
        (40.3894, 71.7864),
    ),
    (
        "Chevrolet Cobalt 2019, avtomat", 132_000_000, None, "cars",
        "Qoʻqon", ListingCondition.used,
        (
            "2019-yil, avtomat korobka. Yurgani 78 000 km. Bir qoʻlda yurgan, "
            "servis kitobchasi bor. Hujjatlar toza, kredit yoʻq."
        ),
        (40.5286, 70.9425),
    ),
    (
        "3 xonali kvartira, 2/5, remontli", 520_000_000, None, "realty",
        "Margʻilon", ListingCondition.none,
        (
            "5 qavatli uyning 2-qavati, 3 xona, 68 m². Yevro taʼmir qilingan, "
            "konditsioner va mebel qoladi. Maktab va bozor yaqin."
        ),
        (40.4711, 71.7244),
    ),
    (
        "Rishton keramikasi, 12 kishilik toʻplam", 380_000, None, "household",
        "Rishton", ListingCondition.fresh,
        (
            "Rishton ustalari qoʻlida ishlangan toʻplam. Anʼanaviy koʻk-oq naqsh, "
            "barchasi qoʻlda chizilgan. Pochta orqali ham joʻnatamiz."
        ),
        (40.3567, 71.2842),
    ),
    (
        "Yumshoq burchak divan, ochiladigan", 3_200_000, None, "furniture",
        "Oltiariq", ListingCondition.used,
        (
            "2 yil ishlatilgan, toza holatda. Ochiladi — 2 kishilik yotoq boʻladi. "
            "Ichida choyshab uchun quti bor. Olib ketish oʻzingizdan."
        ),
        (40.3908, 71.2200),
    ),
    (
        "Margʻilon atlasidan koʻylak, buyurtmaga", 450_000, None, "clothes",
        "Margʻilon", ListingCondition.fresh,
        (
            "Tabiiy Margʻilon atlasidan tikilgan koʻylak. Razmerlar 42 dan 52 gacha. "
            "Buyurtma 3–5 kunda tayyor."
        ),
        None,
    ),
    (
        "Samsung kir yuvish mashinasi 7 kg", 2_850_000, None, "household",
        "Quva", ListingCondition.used,
        "7 kg, 3 yil ishlatilgan. Hamma rejimi ishlaydi, suv oqizmaydi.",
        None,
    ),
    (
        "Yuk tashish xizmati — Labo va Isuzu", 0, None, "services",
        "Fargʻona shahri", ListingCondition.none,
        (
            "Viloyat ichida va tashqarisiga yuk tashiymiz. Labo (1 t) va Isuzu (5 t). "
            "Narx masofaga qarab hisoblanadi."
        ),
        None,
    ),
    (
        "Doʻkonga sotuvchi qiz kerak", 4_500_000, "oy", "jobs",
        "Fargʻona shahri", ListingCondition.none,
        (
            "Markaziy bozor yonidagi kiyim doʻkoniga sotuvchi kerak. "
            "Ish vaqti 09:00–18:00, yakshanba dam. Tajriba shart emas."
        ),
        None,
    ),
    (
        "Sigir sotiladi, buzogʻi bilan", 14_000_000, None, "animals",
        "Quva", ListingCondition.none,
        (
            "Qora-oq sigir, 4 yoshda, 3-tugʻishi. Kuniga 18–20 litr sut beradi. "
            "Buzogʻi 2 oylik. Veterinar hujjatlari bor."
        ),
        None,
    ),
    (
        "Noutbuk Lenovo IdeaPad 3, Ryzen 5", 5_800_000, None, "electro",
        "Fargʻona shahri", ListingCondition.used,
        (
            "Ryzen 5 5500U, 16 GB operativ, 512 GB SSD. Ekran 15.6\" Full HD. "
            "1.5 yil ishlatilgan, faqat oʻqish uchun."
        ),
        None,
    ),
    (
        "iPhone 12 64GB", 3_400_000, None, "phones",
        "Margʻilon", ListingCondition.used,
        "64 GB, oq rang. Batareya 84%, almashtirilgan detali yoʻq.",
        None,
    ),
]

PALETTE = [
    (222, 232, 242), (233, 227, 242), (226, 240, 231),
    (245, 231, 226), (240, 238, 224), (228, 238, 240),
]


def _placeholder(label: str, index: int) -> bytes:
    """Rangli fon + yozuv. Haqiqiy foto emas, shunchaki bo'shliqni to'ldiradi."""
    color = PALETTE[index % len(PALETTE)]
    img = Image.new("RGB", (1200, 900), color)
    draw = ImageDraw.Draw(img)
    draw.rectangle([40, 40, 1160, 860], outline=(255, 255, 255), width=6)
    draw.text((60, 820), label[:48], fill=(120, 134, 128))
    buf = io.BytesIO()
    img.save(buf, "JPEG", quality=88)
    return buf.getvalue()


async def main() -> None:
    async with SessionLocal() as session:
        # Tozalash — seed har safar toza bazadan boshlaydi
        for model in (Favorite, Notification, ListingSpec, ListingPhoto,
                      Listing, LoginToken, User):
            await session.execute(delete(model))
        await session.commit()

        now = datetime.now(UTC)

        admin = User(
            phone="+998901234567",
            phone_verified=True,
            name="Dilshod Rahimov",
            district="Fargʻona shahri",
            role=UserRole.admin,
        )
        session.add(admin)

        users = [
            User(
                phone=phone,
                phone_verified=True,
                name=name,
                district="Fargʻona shahri",
            )
            for name, phone in SELLERS
        ]
        session.add_all(users)
        await session.flush()

        for i, row in enumerate(LISTINGS):
            (title, price, unit, category, district, condition,
             description, point) = row

            owner = users[i % len(users)]
            created = now - timedelta(hours=random.randint(1, 24 * 6))

            listing = Listing(
                owner_id=owner.id,
                title=title,
                description=description,
                price=price,
                price_unit=unit,
                category_id=category,
                condition=condition,
                district=district,
                address="Yangi bozor" if point else None,
                lat=point[0] if point else None,
                lng=point[1] if point else None,
                status=ListingStatus.active,
                views=random.randint(40, 900),
                published_at=created,
                expires_at=created + timedelta(days=30),
            )
            listing.created_at = created
            session.add(listing)
            await session.flush()

            for p in range(random.randint(2, 4)):
                name, w, h = save_photo(_placeholder(f"{title} — {p + 1}", i + p))
                session.add(
                    ListingPhoto(
                        listing_id=listing.id,
                        filename=name,
                        width=w,
                        height=h,
                        position=p,
                    )
                )

        # Moderatsiyada turgan bitta e'lon — panelni sinash uchun
        pending = Listing(
            owner_id=users[0].id,
            title="Velosiped 26 oʻlcham, togʻ velosipedi",
            description="26 oʻlcham, 21 tezlikli. Ramasi alyuminiy, yengil.",
            price=950_000,
            category_id="cars",
            condition=ListingCondition.used,
            district="Oltiariq",
            status=ListingStatus.moderation,
        )
        session.add(pending)
        await session.flush()
        name, w, h = save_photo(_placeholder("Velosiped", 3))
        session.add(
            ListingPhoto(listing_id=pending.id, filename=name, width=w, height=h)
        )

        session.add(
            Notification(
                user_id=admin.id,
                kind=NotificationKind.matched_search,
                title="Siz qidirgan iPhone 13 eʼloni joylandi",
                body="4 500 000 soʻm · Fargʻona shahri",
            )
        )
        await session.commit()

        total = await session.scalar(select(Listing.id))
        print(f"Tayyor. Admin raqami: {admin.phone}")
        print(f"Eʼlonlar yozildi (birinchi id: {total}).")


if __name__ == "__main__":
    asyncio.run(main())
