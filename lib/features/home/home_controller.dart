import 'package:flutter/foundation.dart';

import '../../core/async_value.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/listing_repository.dart';
import '../../state/favorites_controller.dart';

/// Barcha tumanlar — joylashuv tugmasining boshlang'ich qiymati
const allDistricts = 'Fargʻona viloyati';

class HomeController extends ChangeNotifier {
  HomeController(this._repo, this._favorites) {
    load();
  }

  final ListingRepository _repo;
  final FavoritesController _favorites;

  static const _pageSize = 20;

  Async<List<Listing>> state = const Async.loading();
  String? categoryId;
  String district = allDistricts;
  int total = 0;

  bool _loadingMore = false;
  bool _hasMore = false;

  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;

  Future<void> load() async {
    state = const Async.loading();
    notifyListeners();
    await _fetch(reset: true);
  }

  Future<void> refresh() => _fetch(reset: true);

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    notifyListeners();
    await _fetch(reset: false);
  }

  Future<void> _fetch({required bool reset}) async {
    final current = state.valueOrNull ?? const <Listing>[];
    try {
      final page = await _repo.search(
        categoryId: categoryId,
        district: district == allDistricts ? null : district,
        limit: _pageSize,
        offset: reset ? 0 : current.length,
      );

      final items = reset ? page.items : [...current, ...page.items];
      total = page.total;
      _hasMore = page.hasMore;
      state = Async.data(items);

      // Serverdan kelgan "saqlangan" belgilarini umumiy holatga ko'chiramiz
      _favorites.syncFrom({
        for (final item in page.items) item.id: _favorites.isFavorite(item.id),
      });
    } catch (e) {
      // Qo'shimcha sahifa yuklanmasa, borini saqlab qolamiz
      if (reset) {
        state = Async.error('$e');
      }
    }
    _loadingMore = false;
    notifyListeners();
  }

  void selectCategory(String? id) {
    categoryId = categoryId == id ? null : id;
    load();
  }

  void selectDistrict(String value) {
    if (district == value) return;
    district = value;
    load();
  }

  void resetFilters() {
    categoryId = null;
    district = allDistricts;
    load();
  }
}
