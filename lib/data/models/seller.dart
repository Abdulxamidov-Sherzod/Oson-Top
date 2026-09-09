/// E'lon egasi. Reyting va sharh YO'Q — bizda hali sharh tizimi yo'q.
/// Ishonch belgisi sifatida faqat `phoneVerified` va `memberSince` ishlatiladi.
class Seller {
  const Seller({
    required this.id,
    required this.name,
    required this.memberSince,
    required this.listingCount,
    this.phone,
    this.phoneVerified = true,
  });

  factory Seller.fromJson(Map<String, dynamic> json) => Seller(
        id: '${json['id']}',
        name: (json['name'] as String?) ?? 'Foydalanuvchi',
        memberSince: json['member_since'] as int,
        listingCount: json['listing_count'] as int? ?? 0,
        phoneVerified: json['phone_verified'] as bool? ?? false,
      );

  final String id;
  final String name;

  /// Serverdan e'lon bilan birga KELMAYDI — "Raqamni koʻrsatish" bosilganda
  /// alohida so'rov bilan olinadi. Shu sababdan bo'sh bo'lishi mumkin.
  final String? phone;

  /// Ro'yxatdan o'tgan yil, masalan 2023
  final int memberSince;
  final int listingCount;
  final bool phoneVerified;

  /// Avatar uchun bosh harflar — "Sardor Aliyev" → "SA"
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join();
    return letters.toUpperCase();
  }
}
