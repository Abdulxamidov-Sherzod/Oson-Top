/// Kirgan foydalanuvchi: `/me` javobidagi profil va sanoqlar.
class AppUser {
  const AppUser({
    required this.name,
    required this.phone,
    required this.district,
    required this.memberSince,
    required this.activeListings,
    required this.totalListings,
    required this.totalViews,
    this.favorites = 0,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final stats = json['stats'] as Map<String, dynamic>? ?? const {};
    return AppUser(
      name: (user['name'] as String?) ?? '',
      phone: (user['phone'] as String?) ?? '',
      district: (user['district'] as String?) ?? '',
      memberSince: user['member_since'] as int,
      activeListings: stats['active_listings'] as int? ?? 0,
      // Eski serverda bu maydon yoʻq — u holda aktivlar soni koʻrsatiladi
      totalListings: stats['total_listings'] as int? ??
          stats['active_listings'] as int? ??
          0,
      totalViews: stats['total_views'] as int? ?? 0,
      favorites: stats['favorites'] as int? ?? 0,
    );
  }

  /// Foydalanuvchi yozgan ism. Boʻsh boʻlishi mumkin — kirish Telegram
  /// orqali, ism esa faqat profilda qoʻlda kiritiladi.
  final String name;
  final String phone;
  final String district;
  final int memberSince;
  final int activeListings;

  /// Hamma holatdagi eʼlonlar — moderatsiyadagisi ham
  final int totalListings;
  final int totalViews;
  final int favorites;

  /// Ekranda koʻrsatiladigan nom. Ism kiritilmagan boʻlsa ham ekran boʻsh
  /// qolmaydi.
  String get displayName => name.isEmpty ? 'Foydalanuvchi' : name;

  /// `PATCH /me` faqat profilni qaytaradi — sanoqlar oʻzgarmaydi, shuning
  /// uchun ular shu yerda saqlanib qoladi.
  AppUser copyWith({String? name, String? district}) => AppUser(
        name: name ?? this.name,
        phone: phone,
        district: district ?? this.district,
        memberSince: memberSince,
        activeListings: activeListings,
        totalListings: totalListings,
        totalViews: totalViews,
        favorites: favorites,
      );

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }
}
