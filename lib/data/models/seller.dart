/// E'lon egasi. Reyting va sharh YO'Q — bizda hali sharh tizimi yo'q.
/// Ishonch belgisi sifatida faqat `phoneVerified` va `memberSince` ishlatiladi.
class Seller {
  const Seller({
    required this.id,
    required this.name,
    required this.phone,
    required this.memberSince,
    required this.listingCount,
    this.phoneVerified = true,
  });

  final String id;
  final String name;

  /// To'liq raqam. Interfeysda darhol ko'rsatilmaydi —
  /// "Raqamni koʻrsatish" bosilgandan keyin ochiladi.
  final String phone;

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
