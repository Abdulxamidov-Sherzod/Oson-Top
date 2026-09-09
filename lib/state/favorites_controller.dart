import 'package:flutter/foundation.dart';

/// Saqlangan e'lonlar. Bosh sahifadagi yurakcha, e'lon sahifasi va
/// Profil > Saqlanganlar — hammasi shu bitta manbadan foydalanadi.
///
/// Hozircha faqat xotirada. Backend qo'shilganda serverga yoziladi.
class FavoritesController extends ChangeNotifier {
  final Set<String> _ids = {};

  Set<String> get ids => Set.unmodifiable(_ids);
  int get count => _ids.length;
  bool isFavorite(String listingId) => _ids.contains(listingId);

  void toggle(String listingId) {
    if (!_ids.remove(listingId)) _ids.add(listingId);
    notifyListeners();
  }
}
