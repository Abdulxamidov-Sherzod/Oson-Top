import '../mock/mock_listings.dart';
import '../mock/mock_sellers.dart';
import '../models/listing.dart';
import '../models/seller.dart';

/// E'lonlarga yagona kirish nuqtasi. Hozircha mock qaytaradi —
/// backend qo'shilganda faqat shu klass o'zgaradi, ekranlar tegilmaydi.
class ListingRepository {
  ListingRepository() : _items = List.of(mockListings);

  final List<Listing> _items;

  List<Listing> all() => List.unmodifiable(_items);

  Listing? byId(String id) {
    for (final l in _items) {
      if (l.id == id) return l;
    }
    return null;
  }

  Seller sellerOf(Listing listing) => sellerById(listing.sellerId);

  List<Listing> byCategory(String? categoryId) {
    if (categoryId == null) return all();
    return _items.where((l) => l.categoryId == categoryId).toList();
  }

  List<Listing> byIds(Iterable<String> ids) {
    final set = ids.toSet();
    return _items.where((l) => set.contains(l.id)).toList();
  }

  /// O'xshash e'lonlar — bir kategoriyadagi boshqa e'lonlar
  List<Listing> similarTo(Listing listing, {int limit = 6}) => _items
      .where((l) => l.categoryId == listing.categoryId && l.id != listing.id)
      .take(limit)
      .toList();

  /// 4-qismda e'lon berish shu yerga qo'shadi
  void add(Listing listing) => _items.insert(0, listing);
}
