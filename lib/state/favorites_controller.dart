import 'package:flutter/foundation.dart';

import '../data/repositories/favorites_repository.dart';

/// Saqlangan e'lonlar.
///
/// Yurakcha bosilganda ekran darhol o'zgaradi, so'rov keyin ketadi —
/// server rad etsa, holat orqaga qaytariladi.
class FavoritesController extends ChangeNotifier {
  FavoritesController(this._repo);

  final FavoritesRepository _repo;
  final Set<String> _ids = {};

  Set<String> get ids => Set.unmodifiable(_ids);
  int get count => _ids.length;
  bool isFavorite(String listingId) => _ids.contains(listingId);

  /// Serverdan kelgan ro'yxatdagi belgilarni qabul qiladi
  void syncFrom(Map<String, bool> flags) {
    var changed = false;
    flags.forEach((id, isFavorite) {
      if (isFavorite && _ids.add(id)) changed = true;
      if (!isFavorite && _ids.remove(id)) changed = true;
    });
    if (changed) notifyListeners();
  }

  Future<void> load() async {
    try {
      final page = await _repo.list(limit: 50);
      _ids
        ..clear()
        ..addAll(page.items.map((l) => l.id));
      notifyListeners();
    } catch (_) {
      // Kirmagan yoki internet yo'q — belgilar bo'sh qoladi
    }
  }

  Future<void> toggle(String listingId) async {
    final wasFavorite = _ids.contains(listingId);
    if (wasFavorite) {
      _ids.remove(listingId);
    } else {
      _ids.add(listingId);
    }
    notifyListeners();

    try {
      if (wasFavorite) {
        await _repo.remove(listingId);
      } else {
        await _repo.add(listingId);
      }
    } catch (_) {
      // Orqaga qaytaramiz — ekran haqiqatni ko'rsatsin
      if (wasFavorite) {
        _ids.add(listingId);
      } else {
        _ids.remove(listingId);
      }
      notifyListeners();
      rethrow;
    }
  }

  void clear() {
    _ids.clear();
    notifyListeners();
  }
}
