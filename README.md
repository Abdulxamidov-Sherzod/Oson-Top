# Oson Top

Farg'ona viloyati uchun e'lonlar ilovasi. Flutter (iOS/Android) + FastAPI + PostgreSQL.

E'lon qo'yish, qidirish, xaritada joy belgilash va sotuvchi bilan bog'lanish —
soddaligi ataylab: pastda atigi uch bo'lim.

## Nima bor

| | |
|---|---|
| **Ilova** | Bosh sahifa, qidiruv va filtrlar, e'lon sahifasi, e'lon berish (2 qadam), bildirishnomalar, profil |
| **Xarita** | Yandex MapKit — joy tanlash, teskari geokodlash, e'londa ko'rsatish |
| **Kirish** | Telegram bot orqali. SMS yo'q — bot tasdiqlangan raqamni beradi |
| **Moderatsiya** | `/admin` — veb-panel: tasdiqlash, qaytarish, tasdiqni bekor qilish |

## Ikkita qaror

**Kirish Telegram orqali, SMS emas.** O'zbekistonda SMS har biri pul turadi,
Telegram esa deyarli hammada bor va bepul. Bot foydalanuvchidan telefon
raqamini so'raydi — Telegram uni **tasdiqlangan holda** yuboradi, shuning
uchun e'londagi "✓ Raqam tasdiqlangan" belgisi haqiqiy.

**Telefon raqami e'lon bilan birga kelmaydi.** Xaridor "Raqamni ko'rsatish"
tugmasini bosgandan keyin alohida so'rov bilan olinadi. Bu raqam yig'uvchi
botlardan himoya qiladi va sotuvchiga real qiziqish statistikasini beradi.

## Papkalar

```
lib/           Flutter ilovasi
backend/       FastAPI + PostgreSQL (o'z README'si bor)
design/        Dizayn — brauzerda ochiladigan 12 ta ekran
docs/          Ish rejasi
```

## Ishga tushirish

Backend:

```bash
cd backend
cp .env.example .env          # sozlamalarni to'ldiring
python3.12 -m venv .venv && ./.venv/bin/pip install -e ".[dev]"
./.venv/bin/alembic upgrade head
./.venv/bin/python -m app.seed
./.venv/bin/uvicorn app.main:app --reload
```

Ilova:

```bash
./tool/run.sh run --dart-define=api=http://127.0.0.1:8000
```

`tool/run.sh` kerak, chunki Yandex MapKit'ning `full` varianti muhit
o'zgaruvchisi orqali tanlanadi — geokodlash `lite` da yo'q.

## Kalitlar

Uchta sir bor, uchalasi ham git'ga tushmaydi:

| Nima | Qayerda | Namuna |
|---|---|---|
| Telegram bot tokeni | `backend/.env` | `.env.example` |
| MapKit kaliti (iOS) | `ios/Flutter/Secrets.xcconfig` | `Secrets.example.xcconfig` |
| MapKit kaliti (Android) | `android/local.properties` | — |

MapKit kaliti baribir ilova ichiga kiradi (APK'dan chiqarib olish mumkin),
shuning uchun uni Yandex konsolida bundle id'ga bog'lang: `uz.osontop.osonTop`.

## Testlar

```bash
flutter test                        # 14 ta
cd backend && ./.venv/bin/pytest    # 29 ta
```

## Qolgan ish

- Serverga chiqarish (hozir faqat mahalliy)
- Push bildirishnoma
- To'lovli "ko'tarish" (TOP) xizmati

Batafsil: `CLAUDE.md` va `docs/ish-rejasi.html`.
