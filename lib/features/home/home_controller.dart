import 'package:flutter/foundation.dart';
import '../../data/mock/mock_districts.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/listing_repository.dart';

/// Bosh sahifaning holati: tanlangan kategoriya va joylashuv.
class HomeController extends ChangeNotifier {
  HomeController(this._repo);

  final ListingRepository _repo;

  /// null — barcha kategoriyalar
  String? _categoryId;
  String _district = allDistricts;

  String? get categoryId => _categoryId;
  String get district => _district;
  bool get isFiltered => _categoryId != null || _district != allDistricts;

  void selectCategory(String? id) {
    // Tanlangan kategoriyani qayta bosish — filtrni bekor qiladi
    _categoryId = _categoryId == id ? null : id;
    notifyListeners();
  }

  void selectDistrict(String value) {
    if (_district == value) return;
    _district = value;
    notifyListeners();
  }

  List<Listing> get listings {
    var items = _repo.all();
    if (_categoryId != null) {
      items = items.where((l) => l.categoryId == _categoryId).toList();
    }
    if (_district != allDistricts) {
      items = items.where((l) => l.district == _district).toList();
    }
    return items;
  }
}
