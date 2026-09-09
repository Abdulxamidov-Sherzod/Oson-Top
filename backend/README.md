# Oson Top — backend

FastAPI + PostgreSQL. Farg'ona viloyati uchun e'lonlar ilovasining serveri.

## Nima uchun shu tanlov

- **PostgreSQL** — qidiruv, filtr va indekslar uchun. SQLite bilan boshlash
  keyin ko'chirishni qiyinlashtiradi.
- **Telegram orqali kirish** — SMS pul turadi (har biri ~50-100 so'm), Telegram
  bepul. O'zbekistonda Telegram deyarli hammada bor. Bot foydalanuvchidan
  **tasdiqlangan telefon raqamini** so'raydi, shuning uchun "✓ Raqam
  tasdiqlangan" belgisi haqiqiy bo'lib qoladi.
- **Rasmlar diskda** — boshlanishiga yetadi. Trafik oshganda
  `app/services/storage.py` ni S3 mos xizmatga (Cloudflare R2, Backblaze B2)
  o'tkazasiz, qolgan kod tegilmaydi.

## Ishga tushirish

```bash
# 1. Postgres
brew services start postgresql@16
createuser -s oson && createdb -O oson oson_top

# 2. Muhit
python3.12 -m venv .venv
./.venv/bin/pip install -e ".[dev]"
cp .env.example .env          # sozlamalarni to'ldiring

# 3. Baza
./.venv/bin/alembic upgrade head
./.venv/bin/python -m app.seed    # sinov ma'lumotlari

# 4. Server
./.venv/bin/uvicorn app.main:app --reload
```

Hujjatlar: http://127.0.0.1:8000/docs

## Telegram botni sozlash

1. Telegramda [@BotFather](https://t.me/BotFather) ga yozing → `/newbot`
2. Nom va username bering (masalan `OsonTopBot`)
3. Olingan tokenni `.env` ga qo'ying:

```
TELEGRAM_BOT_TOKEN=1234567890:AAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TELEGRAM_BOT_USERNAME=OsonTopBot
```

Ishlab chiqishda `TELEGRAM_WEBHOOK_URL` ni bo'sh qoldiring — server long
polling ishlatadi, domen kerak emas. Serverda domen paydo bo'lgach:

```
TELEGRAM_WEBHOOK_URL=https://api.osontop.uz/api/v1/auth/telegram/webhook
TELEGRAM_WEBHOOK_SECRET=<tasodifiy uzun satr>
```

### Kirish oqimi

```
Ilova                    Backend                  Telegram
  │  POST /auth/telegram/start
  │ ─────────────────────►│
  │  ◄─ token + deep_link │
  │
  │  deep_link ochiladi ─────────────────────────►│
  │                       │  /start <token>       │
  │                       │◄──────────────────────│
  │                       │  "Raqamni ulashish" ─►│
  │                       │◄─ tasdiqlangan raqam  │
  │                       │  hisob yaratiladi     │
  │  GET /auth/telegram/status?token=…
  │ ─────────────────────►│
  │  ◄─ access + refresh  │
```

Token 10 daqiqa yashaydi va bir marta ishlaydi.

## Testlar

```bash
createdb -O oson oson_top_test
./.venv/bin/pytest
```

## Asosiy endpointlar

| Metod | Yo'l | Kirish |
|---|---|---|
| POST | `/api/v1/auth/telegram/start` | — |
| GET | `/api/v1/auth/telegram/status?token=` | — |
| POST | `/api/v1/auth/refresh` | — |
| GET | `/api/v1/listings` | ixtiyoriy |
| GET | `/api/v1/listings/{id}` | ixtiyoriy |
| POST | `/api/v1/listings/{id}/reveal-phone` | — |
| POST | `/api/v1/listings` | majburiy |
| POST | `/api/v1/photos` | majburiy |
| GET/PUT/DELETE | `/api/v1/favorites` | majburiy |
| GET | `/api/v1/notifications` | majburiy |
| GET/PATCH | `/api/v1/me` | majburiy |
| GET | `/api/v1/moderation/queue` | moderator |
| POST | `/api/v1/moderation/listings/{id}/approve` | moderator |

Kirish ixtiyoriy bo'lgan joylarda token bo'lsa "saqlangan" belgisi to'g'ri
ko'rsatiladi, bo'lmasa hammasi `false`.

## Moderatsiya

E'lon `moderation` holatida yaratiladi va lentada ko'rinmaydi. Moderator
tasdiqlaydi yoki sababini yozib qaytaradi — ikkalasida ham egasiga
bildirishnoma boradi.

Odamni moderator qilish:

```sql
UPDATE users SET role = 'moderator' WHERE phone = '+998901234567';
```

Sinov paytida `AUTO_APPROVE=true` qo'ysangiz e'lonlar darhol chiqadi.

## Serverga chiqarish

Kerak bo'ladi: Postgres, Python 3.12, nginx (rasmlar va TLS uchun),
systemd unit yoki Docker. `ALLOW_DEV_LOGIN=false` va yangi `JWT_SECRET`
qo'yishni unutmang — `dev-login` endpointi parolsiz kirish beradi.
