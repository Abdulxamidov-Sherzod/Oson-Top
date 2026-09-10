import 'package:flutter/foundation.dart';

import 'async_value.dart';

/// Bir sahifa natija
class PageResult<T> {
  const PageResult({required this.items, required this.total});

  final List<T> items;
  final int total;
}

typedef PageFetch<T> = Future<PageResult<T>> Function({
  required int limit,
  required int offset,
});

/// Sahifalab yuklanadigan ro'yxat.
///
/// Bitta joyda turadi, chunki lenta, qidiruv, saqlanganlar, mening
/// e'lonlarim va bildirishnomalar — hammasi bir xil ishlaydi: birinchi
/// sahifa, keyin pastga tushganda keyingisi.
class PagedList<T> extends ChangeNotifier {
  PagedList({required this.fetch, this.pageSize = 20});

  final PageFetch<T> fetch;
  final int pageSize;

  Async<List<T>> state = const Async.loading();
  int total = 0;

  bool _loadingMore = false;
  bool _hasMore = false;

  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  List<T> get items => state.valueOrNull ?? const [];

  /// Birinchi sahifani noldan yuklaydi (filtr o'zgarganda ham shu)
  Future<void> load() async {
    state = const Async.loading();
    notifyListeners();
    await _fetchPage(reset: true);
  }

  /// Pastga tortib yangilash — ekranni bo'shatmaydi
  Future<void> refresh() => _fetchPage(reset: true);

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    notifyListeners();
    await _fetchPage(reset: false);
  }

  Future<void> _fetchPage({required bool reset}) async {
    final current = items;
    try {
      final page = await fetch(
        limit: pageSize,
        offset: reset ? 0 : current.length,
      );
      final merged = reset ? page.items : [...current, ...page.items];
      total = page.total;
      _hasMore = merged.length < page.total && page.items.isNotEmpty;
      state = Async.data(merged);
    } catch (error) {
      // Keyingi sahifa kelmasa, borini saqlab qolamiz — bor ro'yxat
      // yo'qolgandan ko'ra qolgani yaxshi
      if (reset) state = Async.error('$error');
    }
    _loadingMore = false;
    notifyListeners();
  }

  /// Ro'yxatdan bitta elementni olib tashlash (masalan saqlanganlardan)
  void removeWhere(bool Function(T) test) {
    final current = state.valueOrNull;
    if (current == null) return;
    final left = current.where((e) => !test(e)).toList();
    if (left.length == current.length) return;
    total -= current.length - left.length;
    state = Async.data(left);
    notifyListeners();
  }

  void replaceAll(List<T> next) {
    state = Async.data(next);
    notifyListeners();
  }
}
