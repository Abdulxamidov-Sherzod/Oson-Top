import '../models/seller.dart';

const mockSellers = <Seller>[
  Seller(id: 's1', name: 'Sardor Aliyev',      phone: '+998 90 512 34 67', memberSince: 2023, listingCount: 9),
  Seller(id: 's2', name: 'Jasur Qodirov',      phone: '+998 93 118 40 92', memberSince: 2020, listingCount: 4),
  Seller(id: 's3', name: 'Nilufar Ahmedova',   phone: '+998 91 245 88 10', memberSince: 2023, listingCount: 3),
  Seller(id: 's4', name: 'Ulugʻbek Nazarov',   phone: '+998 90 604 19 77', memberSince: 2021, listingCount: 41),
  Seller(id: 's5', name: 'Muhabbat Isroilova', phone: '+998 99 512 07 44', memberSince: 2024, listingCount: 1),
  Seller(id: 's6', name: 'Dilnoza Toʻxtasinova', phone: '+998 94 330 71 05', memberSince: 2022, listingCount: 29),
  Seller(id: 's7', name: 'Anvar Sotiboldiyev', phone: '+998 97 442 63 18', memberSince: 2019, listingCount: 2),
  Seller(id: 's8', name: 'Shahnoza Karimova',  phone: '+998 91 807 25 60', memberSince: 2023, listingCount: 5),
  Seller(id: 's9', name: 'Hasan Yusupov',      phone: '+998 90 271 58 83', memberSince: 2022, listingCount: 9),
  Seller(id: 's10', name: 'Aziz Toshmatov',    phone: '+998 90 909 14 56', memberSince: 2021, listingCount: 8),
];

Seller sellerById(String id) =>
    mockSellers.firstWhere((s) => s.id == id, orElse: () => mockSellers.first);
