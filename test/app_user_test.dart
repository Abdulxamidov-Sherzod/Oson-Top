import 'package:flutter_test/flutter_test.dart';
import 'package:oson_top/data/models/app_user.dart';

void main() {
  const me = {
    'user': {
      'id': 1,
      'name': 'Dilshod Rahimov',
      'phone': '+998901234567',
      'district': 'Fargʻona shahri',
      'member_since': 2024,
      'phone_verified': true,
      'role': 'user',
    },
    'stats': {
      'active_listings': 3,
      'total_listings': 5,
      'total_views': 1248,
      'favorites': 27,
    },
  };

  test('/me javobi oʻqiladi', () {
    final user = AppUser.fromJson(me);
    expect(user.name, 'Dilshod Rahimov');
    expect(user.displayName, 'Dilshod Rahimov');
    expect(user.initials, 'DR');
    expect(user.totalListings, 5);
    expect(user.favorites, 27);
  });

  test('ism boʻsh boʻlsa ekranda oʻrniga umumiy soʻz turadi', () {
    final user = AppUser.fromJson({
      'user': {...me['user']!, 'name': null},
      'stats': me['stats'],
    });
    // Tahrirlash formasi aynan shu — boʻsh — qiymatni koʻrsatishi kerak
    expect(user.name, '');
    expect(user.displayName, 'Foydalanuvchi');
    expect(user.initials, '?');
  });

  test('profil saqlangach sanoqlar yoʻqolmaydi', () {
    // PATCH /me faqat profilni qaytaradi, shuning uchun sanoqlar
    // mavjud holatdan olinadi
    final updated = AppUser.fromJson(me).copyWith(name: 'Nodira', district: '');
    expect(updated.name, 'Nodira');
    expect(updated.district, '');
    expect(updated.totalViews, 1248);
    expect(updated.phone, '+998901234567');
    expect(updated.memberSince, 2024);
  });
}
