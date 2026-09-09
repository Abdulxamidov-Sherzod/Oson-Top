# Oson Top

Farg'ona viloyati uchun e'lonlar ilovasi (OLX'ga o'xshash, soddaroq). Flutter, mobil.

**Til:** butun interfeys o'zbek lotin alifbosida. `oʻ` (U+02BB) va `ʼ` (U+02BC) belgilaridan foydalaniladi: `Fargʻona`, `eʼlon`, `koʻrish`. Kod, fayl nomlari va commit'lar inglizcha.

**Valyuta:** so'm, uch xonali bo'shliq bilan — `3 200 000 soʻm`.

## Hozirgi holat

**Frontend tayyor.** Bosh sahifa, qidiruv, e'lon sahifasi, e'lon berish (2 qadam),
bildirishnomalar, profil, saqlanganlar — hammasi ishlaydi.

Backend YO'Q. Hamma ma'lumot `lib/data/mock/` ichidan keladi. Ro'yxatdan o'tish ham
yo'q — foydalanuvchi mock (`mock_user.dart`).

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

`test/` ichida 20 ta test. Widget testlarda ekran o'lchamini shunday bering:

```dart
tester.view.physicalSize = const Size(390, 844);
tester.view.devicePixelRatio = 1.0;
addTearDown(tester.view.reset);
```

`setSurfaceSize` ishlatmang — u fizik o'lchamni qo'yadi va logik ekran 3 barobar
kichrayib ketadi.

## Ish rejasi

To'liq reja: `docs/ish-rejasi.html`. Frontend qismlari (0–4, 6, 7) bajarilgan.
Qolgani: 5-qism (Yandex MapKit) va backend.
