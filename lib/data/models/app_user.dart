/// Foydalanuvchi. Hozircha mock — ro'yxatdan o'tish backend bilan keladi.
class AppUser {
  const AppUser({
    required this.name,
    required this.phone,
    required this.district,
    required this.memberSince,
    required this.activeListings,
    required this.totalViews,
    this.favorites = 0,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final stats = json['stats'] as Map<String, dynamic>? ?? const {};
    return AppUser(
      name: (user['name'] as String?) ?? 'Foydalanuvchi',
      phone: (user['phone'] as String?) ?? '',
      district: (user['district'] as String?) ?? '',
      memberSince: user['member_since'] as int,
      activeListings: stats['active_listings'] as int? ?? 0,
      totalViews: stats['total_views'] as int? ?? 0,
      favorites: stats['favorites'] as int? ?? 0,
    );
  }

  final String name;
  final String phone;
  final String district;
  final int memberSince;
  final int activeListings;
  final int totalViews;
  final int favorites;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }
}
