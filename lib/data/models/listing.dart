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
    this.address,
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

  /// Xaritada belgilangan taxminiy manzil. Ixtiyoriy — 5-qismda to'ldiriladi.
  final String? address;

  final String description;
  final List<ListingSpec> specs;
  final String sellerId;
  final DateTime postedAt;
  final int views;
  final ListingCondition condition;
  final ListingStatus status;

  /// Rasmlar soni. Hozircha haqiqiy rasm yo'q — placeholder chiziladi.
  final int photoCount;

  /// Placeholder ustidagi yozuv, masalan "telefon rasmi"
  final String photoLabel;

  bool get isNegotiable => price == 0;
}
