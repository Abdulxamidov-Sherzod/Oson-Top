import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Xaritadagi nuqtadan manzil topish (teskari geokodlash).
///
/// Yandex to'liq manzilni "Oʻzbekiston, Fargʻona, Toshloq koʻchasi 12"
/// shaklida qaytaradi. Bizga davlat va viloyat kerak emas — e'londa
/// tuman allaqachon alohida ko'rsatiladi.
abstract final class Geocoding {
  static Future<String?> addressOf(Point point) async {
    try {
      final (session, result) = await YandexSearch.searchByPoint(
        point: point,
        zoom: 17,
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          geometry: false,
          resultPageSize: 1,
        ),
      );

      final response = await result;
      session.close();

      if (response.error != null) return null;

      final items = response.items;
      if (items == null || items.isEmpty) return null;

      final address = items.first.toponymMetadata?.address.formattedAddress;
      return address == null ? null : shorten(address);
    } catch (_) {
      // Internet yo'q yoki kalit ishlamadi — koordinata baribir saqlanadi
      return null;
    }
  }

  /// "Oʻzbekiston, Fargʻona viloyati, Fargʻona, Mustaqillik koʻchasi 12"
  /// → "Mustaqillik koʻchasi 12"
  static String shorten(String full) {
    final parts = full.split(',').map((p) => p.trim()).toList()
      ..removeWhere((p) => p.isEmpty);

    final skip = RegExp(
      r'oʻzbekiston|o‘zbekiston|узбекистан|uzbekistan|viloyat|область|tumani|район',
      caseSensitive: false,
    );
    final kept = parts.where((p) => !skip.hasMatch(p)).toList();

    if (kept.isEmpty) return parts.isEmpty ? full : parts.last;
    // Oxirgi ikkitasi eng aniq qismi — ko'cha va uy
    return kept.length <= 2
        ? kept.join(', ')
        : kept.sublist(kept.length - 2).join(', ');
  }
}
