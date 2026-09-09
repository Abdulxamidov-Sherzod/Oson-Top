import '../data/models/listing.dart';

/// Narx, sana va telefon formatlash. Butun ilova shu yerdan foydalanadi.
abstract final class OtFormat {
  static const _months = [
    'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
    'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr',
  ];

  /// 3200000 → "3 200 000"
  static String number(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  /// 3200000 → "3 200 000 soʻm" · 0 → "Kelishiladi" · oylik → "… / oy"
  static String price(int value, {String? unit}) {
    if (value == 0) return 'Kelishiladi';
    final base = '${number(value)} soʻm';
    return unit == null ? base : '$base / $unit';
  }

  static String listingPrice(Listing l) => price(l.price, unit: l.priceUnit);

  /// Yopiq raqam — "Raqamni koʻrsatish" bosilgunicha shu ko'rinadi
  static const maskedPhone = '+998 ХХ ХХХ-ХХ-ХХ';

  /// "22 daqiqa oldin", "2 soat oldin", "Kecha", "3 kun oldin", "8-sentabr"
  static String timeAgo(DateTime at, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final diff = ref.difference(at);

    if (diff.inMinutes < 1) return 'hozir';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';

    final today = DateTime(ref.year, ref.month, ref.day);
    final day = DateTime(at.year, at.month, at.day);
    final dayDiff = today.difference(day).inDays;

    if (dayDiff == 0) return '${diff.inHours} soat oldin';
    if (dayDiff == 1) return 'Kecha';
    if (dayDiff < 7) return '$dayDiff kun oldin';
    return '${at.day}-${_months[at.month - 1]}';
  }

  /// E'lon sahifasidagi to'liq sana — "8-sentabr, 14:20"
  static String fullDate(DateTime at) {
    final hh = at.hour.toString().padLeft(2, '0');
    final mm = at.minute.toString().padLeft(2, '0');
    return '${at.day}-${_months[at.month - 1]}, $hh:$mm';
  }

  /// "2023-yildan beri"
  static String memberSince(int year) => '$year-yildan beri';
}
