import 'package:flutter/foundation.dart';

import '../../data/mock/mock_districts.dart';
import '../../data/models/listing.dart';
import '../../data/recent_searches_store.dart';
import '../../data/repositories/listing_repository.dart';

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
  SearchScreenController(this._repo) {
    _store.load().then((v) {
      _recent = v;
      notifyListeners();
    });
  }

  final ListingRepository _repo;
  final _store = RecentSearchesStore();

  String _query = '';
  String? _categoryId;
  String _district = allDistricts;
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
      _district != allDistricts ||
      !_price.isEmpty ||
      _condition != null;

  /// So'nggi qidiruvlar faqat hech narsa qidirilmaganda ko'rinadi
  bool get showSuggestions => _query.trim().isEmpty && !hasFilters;

  int get activeFilterCount => [
        _categoryId != null,
        _district != allDistricts,
        !_price.isEmpty,
        _condition != null,
      ].where((e) => e).length;

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearQuery() => setQuery('');

  void setCategory(String? id) {
    _categoryId = id;
    notifyListeners();
  }

  void setDistrict(String value) {
    _district = value;
    notifyListeners();
  }

  void setPrice(PriceRange value) {
    _price = value;
    notifyListeners();
  }

  void setCondition(ListingCondition? value) {
    _condition = value;
    notifyListeners();
  }

  void setSort(SortOrder value) {
    _sort = value;
    notifyListeners();
  }

  void resetFilters() {
    _categoryId = null;
    _district = allDistricts;
    _price = const PriceRange();
    _condition = null;
    notifyListeners();
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

  List<Listing> get results {
    final q = _query.trim().toLowerCase();
    var items = _repo.all().where((l) {
      if (_categoryId != null && l.categoryId != _categoryId) return false;
      if (_district != allDistricts && l.district != _district) return false;
      if (!_price.contains(l.price)) return false;
      if (_condition != null && l.condition != _condition) return false;
      if (q.isEmpty) return true;
      return '${l.title} ${l.district} ${l.description}'
          .toLowerCase()
          .contains(q);
    }).toList();

    switch (_sort) {
      case SortOrder.newest:
        items.sort((a, b) => b.postedAt.compareTo(a.postedAt));
      case SortOrder.cheapest:
        // "Kelishiladi" (0) narxi noma'lum — oxiriga tushadi
        items.sort((a, b) => _priceKey(a).compareTo(_priceKey(b)));
      case SortOrder.priciest:
        items.sort((a, b) => _priceKey(b).compareTo(_priceKey(a)));
    }
    return items;
  }

  int _priceKey(Listing l) =>
      l.price == 0 ? (_sort == SortOrder.cheapest ? 1 << 40 : -1) : l.price;
}
