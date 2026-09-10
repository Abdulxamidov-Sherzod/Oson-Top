import 'package:flutter/foundation.dart';

import '../../core/paged_list.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/listing_repository.dart';
import '../../state/favorites_controller.dart';

/// Barcha tumanlar — joylashuv tugmasining boshlang'ich qiymati
const allDistricts = 'Fargʻona viloyati';

class HomeController extends ChangeNotifier {
  HomeController(this._repo, this._favorites) {
    paged = PagedList<Listing>(fetch: _fetch)..addListener(notifyListeners);
    paged.load();
  }

  final ListingRepository _repo;
  final FavoritesController _favorites;

  late final PagedList<Listing> paged;

  String? categoryId;
  String district = allDistricts;

  int get total => paged.total;

  Future<PageResult<Listing>> _fetch({
    required int limit,
    required int offset,
  }) async {
    final page = await _repo.search(
      categoryId: categoryId,
      district: district == allDistricts ? null : district,
      limit: limit,
      offset: offset,
    );
    // Serverdan kelgan "saqlangan" belgilarini umumiy holatga ko'chiramiz
    _favorites.syncFrom({
      for (final item in page.items) item.id: _favorites.isFavorite(item.id),
    });
    return PageResult(items: page.items, total: page.total);
  }

  void selectCategory(String? id) {
    categoryId = categoryId == id ? null : id;
    paged.load();
  }

  void selectDistrict(String value) {
    if (district == value) return;
    district = value;
    paged.load();
  }

  void resetFilters() {
    categoryId = null;
    district = allDistricts;
    paged.load();
  }

  @override
  void dispose() {
    paged
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
