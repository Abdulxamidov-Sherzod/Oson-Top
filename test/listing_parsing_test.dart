import 'package:flutter_test/flutter_test.dart';
import 'package:oson_top/data/models/listing.dart';
import 'package:oson_top/data/models/seller.dart';

/// Server javobini to'g'ri o'qiyotganimizni tekshiradi. API o'zgarsa
/// shu testlar birinchi bo'lib yiqiladi.
void main() {
  test('lentadagi karta oʻqiladi', () {
    final listing = Listing.fromCardJson({
      'id': 14,
      'title': 'iPhone 13 128GB',
      'price': 4500000,
      'price_unit': null,
      'category_id': 'phones',
      'district': 'Fargʻona shahri',
      'created_at': '2026-09-09T09:00:00+00:00',
      'photo': '/media/t_abc.jpg',
      'is_favorite': true,
    });

    expect(listing.id, '14');
    expect(listing.price, 4500000);
    expect(listing.isNegotiable, isFalse);
    expect(listing.thumbUrl, endsWith('/media/t_abc.jpg'));
    expect(listing.thumbUrl, startsWith('http'));
  });

  test('narxi nol boʻlgan eʼlon «Kelishiladi»', () {
    final listing = Listing.fromCardJson({
      'id': 1,
      'title': 'Yuk tashish',
      'price': 0,
      'price_unit': null,
      'category_id': 'services',
      'district': 'Quva',
      'created_at': '2026-09-09T09:00:00+00:00',
      'photo': null,
    });

    expect(listing.isNegotiable, isTrue);
    expect(listing.thumbUrl, isNull);
    expect(listing.hasPhotos, isFalse);
  });

  test('batafsil sahifa oʻqiladi', () {
    final listing = Listing.fromDetailJson({
      'id': 14,
      'title': 'Yumshoq burchak divan',
      'description': 'Toza holatda',
      'price': 3200000,
      'price_unit': null,
      'category_id': 'furniture',
      'condition': 'used',
      'district': 'Oltiariq',
      'address': 'Toshloq koʻchasi 12',
      'lat': 40.39,
      'lng': 71.22,
      'status': 'active',
      'reject_reason': null,
      'views': 312,
      'created_at': '2026-09-09T09:00:00+00:00',
      'photos': [
        {
          'id': 1,
          'url': '/media/a.jpg',
          'thumb_url': '/media/t_a.jpg',
          'width': 1200,
          'height': 900,
        },
        {
          'id': 2,
          'url': '/media/b.jpg',
          'thumb_url': '/media/t_b.jpg',
          'width': 1200,
          'height': 900,
        },
      ],
      'specs': [
        {'label': 'Oʻlchami', 'value': '280 × 180 sm'},
      ],
      'seller': {
        'id': 3,
        'name': 'Sardor Aliyev',
        'member_since': 2023,
        'phone_verified': true,
        'listing_count': 9,
      },
      'is_favorite': false,
    });

    expect(listing.photoUrls, hasLength(2));
    expect(listing.photoCount, 2);
    expect(listing.condition, ListingCondition.used);
    expect(listing.status, ListingStatus.active);
    expect(listing.hasLocation, isTrue);
    expect(listing.specs.single.value, '280 × 180 sm');
  });

  test('sotuvchida telefon maydoni yoʻq — u alohida olinadi', () {
    final seller = Seller.fromJson({
      'id': 3,
      'name': 'Sardor Aliyev',
      'member_since': 2023,
      'phone_verified': true,
      'listing_count': 9,
    });

    expect(seller.phone, isNull);
    expect(seller.phoneVerified, isTrue);
    expect(seller.initials, 'SA');
  });

  test('moderatsiyadagi eʼlon holati oʻqiladi', () {
    final listing = Listing.fromDetailJson({
      'id': 1,
      'title': 'Sinov',
      'description': '',
      'price': 1000,
      'price_unit': null,
      'category_id': 'phones',
      'condition': 'none',
      'district': 'Quva',
      'status': 'moderation',
      'views': 0,
      'created_at': '2026-09-09T09:00:00+00:00',
      'photos': <Map<String, dynamic>>[],
      'specs': <Map<String, dynamic>>[],
      'seller': {
        'id': 1,
        'name': null,
        'member_since': 2026,
        'phone_verified': false,
        'listing_count': 0,
      },
    });

    expect(listing.status, ListingStatus.moderation);
    expect(listing.condition, ListingCondition.none);
  });
}
