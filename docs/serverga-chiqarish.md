# Serverga chiqarish

Sinov uchun to'liq bepul: **Supabase** (baza + rasmlar) + **Render** (backend).

## 1. Supabase

1. [supabase.com](https://supabase.com) → yangi loyiha
2. **Region: Frankfurt** (O'zbekistonga eng yaqin)
3. Baza parolini saqlab qo'ying — keyin ko'rsatilmaydi

**Rasmlar uchun bucket:**

`Storage → New bucket` → nomi **`listing-photos`** → **Public bucket** yoqilsin.
Ochiq bo'lishi kerak, chunki rasmlar ilovaga to'g'ridan-to'g'ri beriladi.

**Kerakli qiymatlar:**

| Qayerdan | Nima |
|---|---|
| `Settings → Database → Connection string → URI` | `DATABASE_URL` |
| `Settings → API → Project URL` | `SUPABASE_URL` |
| `Settings → API → service_role` | `SUPABASE_SERVICE_KEY` |

`DATABASE_URL` da bitta o'zgartirish kerak:

```
postgresql://...        →  postgresql+asyncpg://...
```

## 2. Render

1. [render.com](https://render.com) → GitHub bilan kiring
2. `New → Blueprint` → `Oson-Top` repozitoriysi → `render.yaml` topiladi
3. So'ralgan qiymatlarni to'ldiring:

```
DATABASE_URL           Supabase'dan (asyncpg bilan)
TELEGRAM_BOT_TOKEN     @BotFather dan
SUPABASE_URL           Supabase'dan
SUPABASE_SERVICE_KEY   Supabase'dan
TELEGRAM_WEBHOOK_URL   birinchi chiqarishdan keyin to'ldiriladi
```

Birinchi chiqarish tugagach manzilingiz bo'ladi, masalan
`https://oson-top-api.onrender.com`. Shuni `TELEGRAM_WEBHOOK_URL` ga
qo'ying va qayta chiqaring:

```
https://oson-top-api.onrender.com/api/v1/auth/telegram/webhook
```

## 3. Server uxlamasligi uchun

Render bepul rejasi 15 daqiqa harakatsizlikdan keyin to'xtaydi — keyingi
so'rov 30-60 soniya kutadi.

[cron-job.org](https://cron-job.org) da bepul vazifa yarating:
har **10 daqiqada** `https://oson-top-api.onrender.com/health`.

## 4. Ma'lumot

Migratsiyalar har chiqarishda o'zi yuriladi. Sinov e'lonlarini qo'shish
uchun Render'ning `Shell` bo'limida:

```bash
python -m app.seed
```

**Diqqat:** `seed` bazani tozalaydi. Real e'lonlar paydo bo'lgach ishlatmang.

## 5. Ilovani yangi manzilga ulash

```bash
./tool/run.sh build ios --release \
  --dart-define=api=https://oson-top-api.onrender.com
```

## Tekshirish ro'yxati

- [ ] `ALLOW_DEV_LOGIN=false` — aks holda parolsiz kirish ochiq qoladi
- [ ] `JWT_SECRET` — Render o'zi yaratadi, qo'lda yozmang
- [ ] Bucket **public**
- [ ] `DATABASE_URL` da `+asyncpg`
- [ ] Webhook o'rnatilgani: `https://api.telegram.org/bot<TOKEN>/getWebhookInfo`
