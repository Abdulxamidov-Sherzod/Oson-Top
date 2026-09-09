/// Foydalanuvchi. Hozircha mock — ro'yxatdan o'tish backend bilan keladi.
class AppUser {
  const AppUser({
    required this.name,
    required this.phone,
    required this.district,
    required this.memberSince,
    required this.activeListings,
    required this.totalViews,
  });

  final String name;
  final String phone;
  final String district;
  final int memberSince;
  final int activeListings;
  final int totalViews;

  String get initials {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.length < 2) return name.substring(0, 1).toUpperCase();
    return (p[0][0] + p[1][0]).toUpperCase();
  }
}
