import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../shared/widgets/district_sheet.dart';
import '../../data/models/listing.dart';
import '../../data/recent_searches_store.dart';
import '../../core/paged_list.dart';
import '../../data/repositories/listing_repository.dart';
import '../../state/favorites_controller.dart';

enum SortOrder {
  newest('Eng yangi'),
  cheapest('Arzonidan'),
  priciest('Qimmatidan');

  const SortOrder(this.label);
  final String label;
}

/// Narx oralig'i filtri
class PriceRange {
  const PriceRange({this.min, this.max});

  final int? min;
  final int? max;

  bool get isEmpty => min == null && max == null;

  bool contains(int price) {
    if (min != null && price < min!) return false;
    if (max != null && price > max!) return false;
    return true;
  }
}

class SearchScreenController extends ChangeNotifier {
  SearchScreenController(this._repo, this._favorites) {
    paged = PagedList<Listing>(fetch: _fetch)..addListener(notifyListeners);
    _store.load().then((v) {
      _recent = v;
      notifyListeners();
    });
  }

  final ListingRepository _repo;
  final FavoritesController _favorites;
  final _store = RecentSearchesStore();

  String _query = '';
  String? _categoryId;
  String _district = allDistrictsLabel;
  PriceRange _price = const PriceRange();
  ListingCondition? _condition;
  SortOrder _sort = SortOrder.newest;
  List<String> _recent = const [];

  String get query => _query;
  String? get categoryId => _categoryId;
  String get district => _district;
  PriceRange get price => _price;
  ListingCondition? get condition => _condition;
  SortOrder get sort => _sort;
  List<String> get recent => _recent;

  bool get hasFilters =>
      _categoryId != null ||
      _district != allDistrictsLabel ||
      !_price.isEmpty ||
      _condition != null;

  /// So'nggi qidiruvlar faqat hech narsa qidirilmaganda ko'rinadi
  bool get showSuggestions => _query.trim().isEmpty && !hasFilters;

  int get activeFilterCount => [
        _categoryId != null,
        _district != allDistrictsLabel,
        !_price.isEmpty,
        _condition != null,
      ].where((e) => e).length;

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
    _scheduleSearch();
  }

  void clearQuery() => setQuery('');

  void setCategory(String? id) {
    _categoryId = id;
    notifyListeners();
    search();
  }

  void setDistrict(String value) {
    _district = value;
    notifyListeners();
    search();
  }

  void setPrice(PriceRange value) {
    _price = value;
    notifyListeners();
    search();
  }

  void setCondition(ListingCondition? value) {
    _condition = value;
    notifyListeners();
    search();
  }

  void setSort(SortOrder value) {
    _sort = value;
    notifyListeners();
    search();
  }

  void resetFilters() {
    _categoryId = null;
    _district = allDistrictsLabel;
    _price = const PriceRange();
    _condition = null;
    notifyListeners();
    search();
  }

  Future<void> saveQuery() async {
    _recent = await _store.add(_query);
    notifyListeners();
  }

  Future<void> removeRecent(String q) async {
    _recent = await _store.remove(q);
    notifyListeners();
  }

  Future<void> clearRecent() async {
    _recent = await _store.clear();
    notifyListeners();
  }

  late final PagedList<Listing> paged;

  Timer? _debounce;

  int get total => paged.total;

  /// Har harfda so'rov ketmasin — 350 ms kutamiz
  void _scheduleSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), search);
  }

  Future<PageResult<Listing>> _fetch({
    required int limit,
    required int offset,
  }) async {
    final page = await _repo.search(
      query: _query,
      categoryId: _categoryId,
      district: _district == allDistrictsLabel ? null : _district,
      priceMin: _price.min,
      priceMax: _price.max,
      condition: switch (_condition) {
        ListingCondition.fresh => 'fresh',
        ListingCondition.used => 'used',
        _ => null,
      },
      sort: switch (_sort) {
        SortOrder.newest => 'new',
        SortOrder.cheapest => 'cheap',
        SortOrder.priciest => 'expensive',
      },
      limit: limit,
      offset: offset,
    );
    _favorites.syncFrom({
      for (final item in page.items) item.id: _favorites.isFavorite(item.id),
    });
    return PageResult(items: page.items, total: page.total);
  }

  Future<void> search() async {
    if (showSuggestions) {
      paged.replaceAll(const []);
      return;
    }
    await paged.load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    paged
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
