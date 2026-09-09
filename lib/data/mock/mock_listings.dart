import '../models/listing.dart';

/// Dizayndagi e'lonlar. Vaqtlar ilova ochilgan paytga nisbatan hisoblanadi,
/// shuning uchun lenta har doim "yangi" ko'rinadi.
final DateTime _now = DateTime.now();
DateTime _ago({int d = 0, int h = 0, int m = 0}) =>
    _now.subtract(Duration(days: d, hours: h, minutes: m));

final mockListings = <Listing>[
  Listing(
    id: 'l1',
    title: 'iPhone 13 128GB, ideal holat, quti bilan',
    price: 4500000,
    categoryId: 'phones',
    district: 'Fargʻona shahri',
    address: 'Yangi bozor',
    lat: 40.3894,
    lng: 71.7864,
    condition: ListingCondition.used,
    photoCount: 6,
    photoLabel: 'telefon rasmi',
    views: 312,
    postedAt: _ago(h: 2),
    sellerId: 's1',
    description:
        'Telefon 1 yil ishlatilgan, hech qanday nuqsoni yoʻq. Batareya holati 92%. '
        'Quti, original kabel va himoya gʻilofi bilan beriladi. Kelishish mumkin, '
        'almashtirish yoʻq. Fargʻona shahrida koʻrish mumkin.',
    specs: [
      ListingSpec('Model', 'iPhone 13'),
      ListingSpec('Xotira', '128 GB'),
      ListingSpec('Batareya', '92%'),
      ListingSpec('Rangi', 'Sierra Blue'),
      ListingSpec('Komplekt', 'Quti, kabel'),
    ],
  ),
  Listing(
    id: 'l2',
    title: 'Chevrolet Cobalt 2019, avtomat',
    price: 132000000,
    categoryId: 'cars',
    district: 'Qoʻqon',
    address: 'Istiqlol koʻchasi',
    lat: 40.5286,
    lng: 70.9425,
    condition: ListingCondition.used,
    photoCount: 8,
    photoLabel: 'avtomobil rasmi',
    views: 733,
    postedAt: _ago(h: 5),
    sellerId: 's2',
    description:
        '2019-yil, avtomat korobka. Yurgani 78 000 km. Bir qoʻlda yurgan, servis '
        'kitobchasi bor. Rangi kumush. Hujjatlar toza, kredit yoʻq. Bahosi biroz kelishiladi.',
    specs: [
      ListingSpec('Marka', 'Chevrolet Cobalt'),
      ListingSpec('Yili', '2019'),
      ListingSpec('Yurgani', '78 000 km'),
      ListingSpec('Uzatma', 'Avtomat'),
      ListingSpec('Rangi', 'Kumush'),
    ],
  ),
  Listing(
    id: 'l3',
    title: '3 xonali kvartira, 2/5, remontli',
    price: 520000000,
    categoryId: 'realty',
    district: 'Margʻilon',
    address: 'Toshkent koʻchasi 24',
    lat: 40.4711,
    lng: 71.7244,
    condition: ListingCondition.none,
    photoCount: 10,
    photoLabel: 'kvartira rasmi',
    views: 874,
    postedAt: _ago(h: 8),
    sellerId: 's3',
    description:
        '5 qavatli uyning 2-qavati, 3 xona, 68 m². Yevro taʼmir qilingan, '
        'konditsioner va mebel qoladi. Maktab va bozor yaqin. Hujjatlari toʻliq, '
        'vositachilarsiz.',
    specs: [
      ListingSpec('Xonalar', '3'),
      ListingSpec('Maydoni', '68 m²'),
      ListingSpec('Qavat', '2 / 5'),
      ListingSpec('Taʼmir', 'Yevro'),
      ListingSpec('Hujjat', 'Toʻliq'),
    ],
  ),
  Listing(
    id: 'l4',
    title: 'Rishton keramikasi, 12 kishilik dasturxon toʻplami',
    price: 380000,
    categoryId: 'household',
    district: 'Rishton',
    address: 'Kulollar mahallasi',
    lat: 40.3567,
    lng: 71.2842,
    condition: ListingCondition.fresh,
    photoCount: 5,
    photoLabel: 'servis rasmi',
    views: 151,
    postedAt: _ago(d: 1),
    sellerId: 's4',
    description:
        'Rishton ustalari qoʻlida ishlangan toʻplam: 12 ta lagan, 12 ta kosa, '
        '2 ta katta lagan. Anʼanaviy koʻk-oq naqsh, barchasi qoʻlda chizilgan. '
        'Ehtiyot qilib qadoqlab beramiz, pochta orqali ham joʻnatamiz.',
    specs: [
      ListingSpec('Buyumlar', '26 dona'),
      ListingSpec('Uslub', 'Anʼanaviy koʻk-oq'),
      ListingSpec('Ishlanishi', 'Qoʻlda'),
      ListingSpec('Qadoq', 'Bor'),
    ],
  ),
  Listing(
    id: 'l5',
    title: 'Samsung kir yuvish mashinasi 7 kg',
    price: 2850000,
    categoryId: 'household',
    district: 'Quva',
    condition: ListingCondition.used,
    photoCount: 4,
    photoLabel: 'mashina rasmi',
    views: 204,
    postedAt: _ago(h: 3),
    sellerId: 's5',
    description:
        '7 kg, 3 yil ishlatilgan. Hamma rejimi ishlaydi, suv oqizmaydi. '
        'Koʻchib ketayotganimiz uchun sotilyapti. Oʻzingiz olib ketasiz.',
    specs: [
      ListingSpec('Sigʻimi', '7 kg'),
      ListingSpec('Yoshi', '3 yil'),
      ListingSpec('Holati', 'Ishchi'),
    ],
  ),
  Listing(
    id: 'l6',
    title: 'Yumshoq burchak divan, ochiladigan',
    price: 3200000,
    categoryId: 'furniture',
    district: 'Oltiariq',
    address: 'Toshloq koʻchasi 12',
    lat: 40.3908,
    lng: 71.2200,
    condition: ListingCondition.used,
    photoCount: 3,
    photoLabel: 'divan rasmi',
    views: 198,
    postedAt: _ago(d: 1, h: 4),
    sellerId: 's5',
    description:
        '2 yil ishlatilgan, toza holatda. Ochiladi — 2 kishilik yotoq boʻladi. '
        'Ichida choyshab uchun quti bor. Olib ketish oʻzingizdan.',
    specs: [
      ListingSpec('Turi', 'Burchak, ochiladigan'),
      ListingSpec('Yoshi', '2 yil'),
      ListingSpec('Oʻlchami', '280 × 180 sm'),
      ListingSpec('Rangi', 'Kulrang'),
    ],
  ),
  Listing(
    id: 'l7',
    title: 'Margʻilon atlasidan koʻylak, buyurtmaga',
    price: 450000,
    categoryId: 'clothes',
    district: 'Margʻilon',
    condition: ListingCondition.fresh,
    photoCount: 7,
    photoLabel: 'kiyim rasmi',
    views: 174,
    postedAt: _ago(h: 6),
    sellerId: 's6',
    description:
        'Tabiiy Margʻilon atlasidan tikilgan koʻylak. Razmerlar 42 dan 52 gacha. '
        'Rang va naqshni oʻzingiz tanlaysiz. Buyurtma 3–5 kunda tayyor. '
        'Viloyat boʻylab yetkazib berish bor.',
    specs: [
      ListingSpec('Mato', 'Tabiiy atlas'),
      ListingSpec('Razmer', '42–52'),
      ListingSpec('Tayyorlash', '3–5 kun'),
      ListingSpec('Yetkazish', 'Bor'),
    ],
  ),
  Listing(
    id: 'l8',
    title: 'iPhone 13 Pro 256GB',
    price: 6900000,
    categoryId: 'phones',
    district: 'Fargʻona shahri',
    condition: ListingCondition.used,
    photoCount: 5,
    photoLabel: 'telefon rasmi',
    views: 421,
    postedAt: _ago(h: 1),
    sellerId: 's1',
    description:
        '256 GB, grafit rang. Batareya 88%. Ekran va korpusda chizilgan joyi yoʻq, '
        'doim gʻilofda yurgan. Quti bor, zaryadlagich yoʻq.',
    specs: [
      ListingSpec('Model', 'iPhone 13 Pro'),
      ListingSpec('Xotira', '256 GB'),
      ListingSpec('Batareya', '88%'),
      ListingSpec('Rangi', 'Grafit'),
    ],
  ),
  Listing(
    id: 'l9',
    title: 'iPhone 12 64GB',
    price: 3400000,
    categoryId: 'phones',
    district: 'Margʻilon',
    condition: ListingCondition.used,
    photoCount: 4,
    photoLabel: 'telefon rasmi',
    views: 288,
    postedAt: _ago(h: 4),
    sellerId: 's6',
    description:
        '64 GB, oq rang. Batareya 84%, almashtirilgan detali yoʻq. '
        'Face ID ishlaydi. Faqat telefon, qutisi yoʻq.',
    specs: [
      ListingSpec('Model', 'iPhone 12'),
      ListingSpec('Xotira', '64 GB'),
      ListingSpec('Batareya', '84%'),
    ],
  ),
  Listing(
    id: 'l10',
    title: 'Samsung S22, ideal holat',
    price: 4100000,
    categoryId: 'phones',
    district: 'Rishton',
    condition: ListingCondition.used,
    photoCount: 6,
    photoLabel: 'telefon rasmi',
    views: 176,
    postedAt: _ago(d: 2),
    sellerId: 's4',
    description:
        '8/128 GB, qora rang. 10 oy ishlatilgan, ekranda plyonka bor. '
        'Quti va zaryadlagich kabeli bilan.',
    specs: [
      ListingSpec('Model', 'Galaxy S22'),
      ListingSpec('Xotira', '8 / 128 GB'),
      ListingSpec('Rangi', 'Qora'),
    ],
  ),
  Listing(
    id: 'l11',
    title: 'Yuk tashish xizmati — Labo va Isuzu',
    price: 0,
    categoryId: 'services',
    district: 'Fargʻona shahri',
    condition: ListingCondition.none,
    photoCount: 3,
    photoLabel: 'mashina rasmi',
    views: 302,
    postedAt: _ago(d: 1),
    sellerId: 's7',
    description:
        'Viloyat ichida va tashqarisiga yuk tashiymiz. Labo (1 t) va Isuzu (5 t) mavjud. '
        'Koʻchish, mebel, qurilish materiallari. Yuk ortuvchi ishchilar ham bor. '
        'Narx masofaga qarab hisoblanadi.',
    specs: [
      ListingSpec('Transport', 'Labo, Isuzu'),
      ListingSpec('Yuk sigʻimi', '1 t / 5 t'),
      ListingSpec('Hudud', 'Viloyat + tashqari'),
    ],
  ),
  Listing(
    id: 'l12',
    title: 'Doʻkonga sotuvchi qiz kerak',
    price: 4500000,
    priceUnit: 'oy',
    categoryId: 'jobs',
    district: 'Fargʻona shahri',
    condition: ListingCondition.none,
    photoCount: 2,
    photoLabel: 'doʻkon rasmi',
    views: 1105,
    postedAt: _ago(d: 2, h: 3),
    sellerId: 's8',
    description:
        'Markaziy bozor yonidagi kiyim doʻkoniga sotuvchi kerak. '
        'Ish vaqti 09:00–18:00, yakshanba dam. Tajriba shart emas, oʻrgatamiz. '
        'Oylik 4 500 000 soʻmdan boshlanadi + sotuvdan foiz.',
    specs: [
      ListingSpec('Ish vaqti', '09:00–18:00'),
      ListingSpec('Dam olish', 'Yakshanba'),
      ListingSpec('Tajriba', 'Shart emas'),
    ],
  ),
  Listing(
    id: 'l13',
    title: 'Sigir sotiladi, buzogʻi bilan',
    price: 14000000,
    categoryId: 'animals',
    district: 'Quva',
    condition: ListingCondition.none,
    photoCount: 4,
    photoLabel: 'hayvon rasmi',
    views: 267,
    postedAt: _ago(d: 3),
    sellerId: 's9',
    description:
        'Qora-oq sigir, 4 yoshda, 3-tugʻishi. Kuniga 18–20 litr sut beradi. '
        'Buzogʻi 2 oylik, urgʻochi. Ikkalasi birga sotiladi. '
        'Veterinar hujjatlari bor, emlangan.',
    specs: [
      ListingSpec('Yoshi', '4 yosh'),
      ListingSpec('Sut', '18–20 l / kun'),
      ListingSpec('Buzoq', '2 oylik, urgʻochi'),
      ListingSpec('Hujjat', 'Veterinar bor'),
    ],
  ),
  Listing(
    id: 'l14',
    title: 'Noutbuk Lenovo IdeaPad 3, Ryzen 5',
    price: 5800000,
    categoryId: 'electro',
    district: 'Fargʻona shahri',
    condition: ListingCondition.used,
    photoCount: 5,
    photoLabel: 'noutbuk rasmi',
    views: 321,
    postedAt: _ago(d: 4),
    sellerId: 's10',
    description:
        'Ryzen 5 5500U, 16 GB operativ, 512 GB SSD. Ekran 15.6" Full HD. '
        '1.5 yil ishlatilgan, faqat oʻqish uchun. Batareyasi 4–5 soat chidaydi. '
        'Zaryadlagichi bor, sumkasi ham qoʻshib beriladi.',
    specs: [
      ListingSpec('Protsessor', 'Ryzen 5 5500U'),
      ListingSpec('Operativ', '16 GB'),
      ListingSpec('Xotira', '512 GB SSD'),
      ListingSpec('Ekran', '15.6" FHD'),
    ],
  ),
];
