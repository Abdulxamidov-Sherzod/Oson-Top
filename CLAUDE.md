# Oson Top

Farg'ona viloyati uchun e'lonlar ilovasi (OLX'ga o'xshash, soddaroq). Flutter, mobil.

**Til:** butun interfeys o'zbek lotin alifbosida. `oʻ` (U+02BB) va `ʼ` (U+02BC) belgilaridan foydalaniladi: `Fargʻona`, `eʼlon`, `koʻrish`. Kod, fayl nomlari va commit'lar inglizcha.

**Valyuta:** so'm, uch xonali bo'shliq bilan — `3 200 000 soʻm`.

## Hozirgi holat

**Frontend va backend tayyor va bir-biriga ulangan.** Mock ma'lumot yo'q —
hamma narsa serverdan keladi.

Backend: `backend/` (FastAPI + PostgreSQL). O'z README'si bor.
Kirish **Telegram bot orqali** — SMS yo'q. Bot foydalanuvchidan tasdiqlangan
telefon raqamini so'raydi, shuning uchun "✓ Raqam tasdiqlangan" haqiqiy.

**Tugallanmagan bitta joy:** haqiqiy Yandex MapKit ulanmagan. E'lon sahifasidagi
xarita — `StaticMapCard`, ya'ni chizma. E'lon berish formasidagi "Xaritada belgilash"
hozircha manzilni qo'lda qo'yadi. Ikkalasi ham MapKit kelganda almashtiriladi;
API kalit kerak.

## Dizayn

Manba: `design/oson-top-dizayn.html` — brauzerda ochib ko'ring, 12 ta ekran bor.
Komponent fayllari: `design/fargona-bozor/*.dc.html` (Claude Design formati, oddiy HTML).

Ekran nomlari dizaynda: `01 · BOSH SAHIFA`, `02 · QIDIRUV`, `03 · EʼLON SAHIFASI`,
`04 · BILDIRISHNOMALAR` (+ `04b` bo'sh), `05 · EʼLON BERISH` (+ `05a` scroll, `05b` 2-qadam,
`05c` xarita), `06 · PROFIL`, `07 · SAQLANGANLAR` (+ `07b` bo'sh).

Kod yozishdan oldin tegishli ekranni dizayndan ko'ring. Ranglar va o'lchamlarni ko'zdan
chiqarmang — aniq qiymatlar `lib/core/theme/` da.

### Muhim dizayn qoidalari

- **Soxta status bar chizilmaydi.** Dizaynda ekran tepasida 50px bo'sh joy bor — bu tizim
  status bari uchun. Flutter'da `SafeArea` bu ishni o'zi qiladi.
- **Telefon raqami yopiq.** E'lon sahifasida raqam darhol ko'rinmaydi — `Raqamni koʻrsatish`
  bosilgandan keyin ochiladi. Bu spam botlardan himoya.
- **Reyting va sharh yo'q.** Sotuvchi kartasida `✓ Raqam tasdiqlangan` va `2023-yildan beri ·
  N ta eʼlon` bor, yulduzcha yo'q — bizda sharh tizimi yo'q.
- **Xavfsizlik ogohlantirishi** e'lon sahifasida majburiy (sariq blok).
- **Moderatsiya** — e'lon darhol chiqmaydi, foydalanuvchiga shu aytiladi.
- **Pastda faqat 3 ta tab:** Bosh sahifa · E'lon berish · Profil. Qidiruv va Bildirishnoma
  tab EMAS — ular bosh sahifadan ochiladi.

## Papka tuzilmasi

```
lib/
  main.dart              — ishga tushirish
  app.dart               — MaterialApp, tema, router
  core/
    theme/
      ot_colors.dart     — ranglar
      ot_radius.dart     — radius va o'lchamlar
      ot_text.dart       — matn uslublari
      ot_theme.dart      — ThemeData
    format.dart          — narx, sana, telefon formatlash
  data/
    models/              — Listing, Category, Seller, AppNotification
    mock/                — mock ma'lumotlar
    repositories/        — hozircha mock'ni qaytaradi
  features/
    home/ search/ listing_detail/ create_listing/ map_picker/
    notifications/ profile/
      <nom>_screen.dart          — ekran
      <nom>_controller.dart      — ChangeNotifier
      widgets/                   — faqat shu ekranga tegishli widgetlar
  shared/
    widgets/             — bir necha ekranda ishlatiladigan widgetlar
```

## Kelishuvlar

- **State:** `provider` + `ChangeNotifier`. Boshqa kutubxona qo'shmang.
- **Server bilan aloqa** faqat `lib/data/repositories/` orqali. Ekranlar
  `dio` ni to'g'ridan-to'g'ri ishlatmaydi.
- **Yuklanadigan ma'lumot** `Async<T>` bilan uzatiladi (`lib/core/async_value.dart`) —
  uchala holat ham (yuklanmoqda / xato / tayyor) ekranda ko'rsatilishi shart.
- **Token** `flutter_secure_storage` da. Eskirganda `ApiClient` o'zi yangilaydi.
- **Nom berish:** fayllar `snake_case.dart`, klasslar `PascalCase`.
  Umumiy widgetlar `Ot` prefiksi bilan: `OtButton`, `OtChip`, `OtTextField`.
  Ekranga xos widgetlar prefiksiz: `HomeHeader`, `SellerCard`.
- **Ranglar** faqat `OtColors` dan olinadi. Kodda `Color(0xFF...)` yozilmaydi.
- **Matn uslublari** faqat `OtText` dan. `TextStyle(...)` inline yozilmaydi.
- **Bo'shliqlar** 4px qadam bilan: 4, 8, 12, 16, 20, 24.
- **Karta balandligi qattiq hisoblanmaydi.** `ListingCard` ichida rasm `Expanded` —
  qolgan joyni o'zi to'ldiradi. Shrift metrikasi platformadan platformaga farq
  qiladi, qattiq hisoblasangiz overflow chiqadi.
- **Mustaqil ishlaydigan ekran** `Material` yoki `Scaffold` ichida bo'lsin —
  `TextField` Material ajdodini talab qiladi.
- **Bosish maydoni** hech qachon 44px dan kichik emas.
- Har bir ekran `SafeArea` ichida.
- Rasm yo'q joyda `OtPhotoPlaceholder` ishlatiladi (chiziqli fon, dizayndagidek).

## Ishga tushirish

```bash
flutter run                      # ulangan qurilma yoki simulyator
flutter analyze                  # xatolarni tekshirish
flutter test                     # testlar
open -a Simulator                # iOS simulyatorini ochish
```

### Xarita — Yandex MapKit

Ikkita narsa muhim:

1. **Kalit git'ga tushmaydi.** iOS uchun `ios/Flutter/Secrets.xcconfig`
   (namuna: `Secrets.example.xcconfig`), Android uchun `android/local.properties`
   ichida `mapkit.apiKey=...`. Ikkalasi ham `.gitignore` da.
2. **`full` variant kerak.** MapKit'ning `lite` varianti faqat xaritani
   ko'rsatadi — teskari geokodlash (nuqtadan manzil topish) unda yo'q.
   Variant muhit o'zgaruvchisi orqali tanlanadi, shuning uchun flutter'ni
   to'g'ridan-to'g'ri emas, `tool/run.sh` orqali chaqiring:

```bash
./tool/run.sh run                      # flutter run o'rniga
./tool/run.sh build ios --simulator    # flutter build o'rniga
```

Variantni o'zgartirgandan keyin: `flutter clean` va DerivedData'ni tozalash.

### Server manzili

Standart: `http://127.0.0.1:8000` (iOS simulyatori uchun). Boshqasi kerak bo'lsa:

```bash
flutter run --dart-define=api=http://192.168.1.50:8000   # haqiqiy telefon
flutter run --dart-define=api=http://10.0.2.2:8000       # Android emulyatori
```

Ilova ishlashi uchun backend ishlab turishi shart:

```bash
cd backend && ./.venv/bin/uvicorn app.main:app --reload
```

### To'g'ridan-to'g'ri kerakli ekranni ochish

Simulyatorda bosib yurmaslik uchun `lib/app.dart` da debug kirish nuqtasi bor:

```bash
flutter run --dart-define=start=search          # qidiruv
flutter run --dart-define=start=detail          # e'lon sahifasi
flutter run --dart-define=start=detail_bottom   # e'lonning pastki qismi (xarita)
flutter run --dart-define=start=create          # e'lon berish
flutter run --dart-define=start=notifications   # bildirishnomalar
flutter run --dart-define=start=profile         # profil
```

Bo'sh bo'lsa odatdagidek bosh sahifadan boshlanadi. Bu faqat ishlab chiqish uchun —
relizga chiqishdan oldin olib tashlanadi.

## Testlar

`test/` ichida 13 ta test (formatlash va server javobini o'qish).
Backend testlari: `cd backend && ./.venv/bin/pytest` — 25 ta. Widget testlarda ekran o'lchamini shunday bering:

```dart
tester.view.physicalSize = const Size(390, 844);
tester.view.devicePixelRatio = 1.0;
addTearDown(tester.view.reset);
```

`setSurfaceSize` ishlatmang — u fizik o'lchamni qo'yadi va logik ekran 3 barobar
kichrayib ketadi.

## Qolgan ish

1. **Serverga chiqarish** — backend hozir faqat shu Mac'da ishlaydi.
2. **Moderatsiya paneli** — API tayyor, veb-interfeys yo'q.
3. **Push bildirishnoma** — hozir ilova ochilganda so'rab oladi.
4. **Xaritada manzil qidiruvi** — tepadagi qatorga yozib qidirish hali yo'q,
   faqat surib tanlash ishlaydi.

To'liq reja: `docs/ish-rejasi.html`.
