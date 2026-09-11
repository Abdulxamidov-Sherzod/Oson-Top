import '../../core/env.dart';

/// E'lon holati — Yangi / Ishlatilgan. Ba'zi kategoriyalarda (ish, xizmat)
/// mos kelmaydi, shuning uchun `none` bor.
enum ListingCondition {
  fresh('Yangi'),
  used('Ishlatilgan'),
  none('—');

  const ListingCondition(this.label);
  final String label;
}

/// E'lonning saytdagi holati
enum ListingStatus {
  active('Aktiv'),
  moderation('Moderatsiyada'),
  rejected('Qaytarilgan'),
  expired('Muddati tugagan');

  const ListingStatus(this.label);
  final String label;
}

/// Batafsil sahifadagi "Ma'lumotlar" jadvali qatori
class ListingSpec {
  const ListingSpec(this.label, this.value);
  final String label;
  final String value;
}

class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.categoryId,
    required this.district,
    required this.description,
    required this.sellerId,
    required this.postedAt,
    required this.views,
    this.priceUnit,
    this.condition = ListingCondition.used,
    this.specs = const [],
    this.photoCount = 1,
    this.photoLabel = 'rasm',
    this.photoUrls = const [],
    this.photoIds = const [],
    this.thumbUrl,
    this.address,
    this.lat,
    this.lng,
    this.status = ListingStatus.active,
  });

  final String id;
  final String title;

  /// So'mda. 0 bo'lsa — "Kelishiladi".
  final int price;

  /// Davriy narx uchun: 'oy'. null bo'lsa — bir martalik narx.
  final String? priceUnit;

  final String categoryId;
  final String district;

  /// Xaritada belgilangan taxminiy manzil. Ixtiyoriy.
  final String? address;

  /// Xaritadagi nuqta. Ixtiyoriy — sotuvchi belgilamasa null bo'ladi va
  /// e'lon sahifasida xarita ko'rsatilmaydi.
  final double? lat;
  final double? lng;

  bool get hasLocation => lat != null && lng != null;

  final String description;
  final List<ListingSpec> specs;
  final String sellerId;
  final DateTime postedAt;
  final int views;
  final ListingCondition condition;
  final ListingStatus status;

  /// Rasmlar soni. Serverdan kelganda `photoUrls.length` ga teng.
  final int photoCount;

  /// Rasm hali yo'q bo'lganda placeholder ustidagi yozuv
  final String photoLabel;

  /// To'liq o'lchamdagi rasmlar — galereya uchun
  final List<String> photoUrls;

  /// Serverdagi rasm id'lari — tahrirlashda qaytadan yuboriladi.
  /// Faqat e'lon sahifasi javobida to'ladi.
  final List<int> photoIds;

  /// Lentadagi karta uchun kichik rasm
  final String? thumbUrl;

  bool get hasPhotos => photoUrls.isNotEmpty || thumbUrl != null;

  bool get isNegotiable => price == 0;

  /// Lentadagi karta uchun — serverdan kam maydon keladi
  factory Listing.fromCardJson(Map<String, dynamic> json) => Listing(
        id: '${json['id']}',
        title: json['title'] as String,
        price: json['price'] as int,
        priceUnit: json['price_unit'] as String?,
        categoryId: json['category_id'] as String,
        district: json['district'] as String,
        description: '',
        sellerId: '',
        postedAt: DateTime.parse(json['created_at'] as String).toLocal(),
        views: 0,
        thumbUrl: _media(json['photo'] as String?),
        photoCount: json['photo'] == null ? 0 : 1,
      );

  factory Listing.fromDetailJson(Map<String, dynamic> json) {
    final photos = (json['photos'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return Listing(
      id: '${json['id']}',
      title: json['title'] as String,
      price: json['price'] as int,
      priceUnit: json['price_unit'] as String?,
      categoryId: json['category_id'] as String,
      district: json['district'] as String,
      address: json['address'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      description: json['description'] as String? ?? '',
      sellerId: '${(json['seller'] as Map<String, dynamic>)['id']}',
      postedAt: DateTime.parse(json['created_at'] as String).toLocal(),
      views: json['views'] as int? ?? 0,
      condition: _condition(json['condition'] as String?),
      status: _status(json['status'] as String?),
      specs: (json['specs'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map((s) => ListingSpec(s['label'] as String, s['value'] as String))
          .toList(),
      photoUrls: photos.map((p) => _media(p['url'] as String)!).toList(),
      photoIds: photos.map((p) => p['id'] as int).toList(),
      thumbUrl: photos.isEmpty ? null : _media(photos.first['thumb_url'] as String),
      photoCount: photos.length,
    );
  }

  static String? _media(String? path) =>
      path == null ? null : Env.media(path);

  static ListingCondition _condition(String? raw) => switch (raw) {
        'fresh' => ListingCondition.fresh,
        'used' => ListingCondition.used,
        _ => ListingCondition.none,
      };

  static ListingStatus _status(String? raw) => switch (raw) {
        'active' => ListingStatus.active,
        'moderation' => ListingStatus.moderation,
        'rejected' => ListingStatus.rejected,
        _ => ListingStatus.expired,
      };
}
