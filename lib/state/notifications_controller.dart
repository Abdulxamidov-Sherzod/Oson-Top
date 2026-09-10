import 'package:flutter/foundation.dart';

import '../core/paged_list.dart';
import '../data/models/app_notification.dart';
import '../data/repositories/notifications_repository.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController(this._repo) {
    paged = PagedList<AppNotification>(fetch: _fetch)
      ..addListener(notifyListeners);
  }

  final NotificationsRepository _repo;

  late final PagedList<AppNotification> paged;
  int _unread = 0;

  List<AppNotification> get items => paged.items;
  int get unreadCount => _unread;

  Future<PageResult<AppNotification>> _fetch({
    required int limit,
    required int offset,
  }) async {
    final page = await _repo.list(limit: limit, offset: offset);
    return PageResult(items: page.items, total: page.total);
  }

  /// Bosh sahifadagi badge uchun — ro'yxatning o'zi kerak emas
  Future<void> refreshBadge() async {
    _unread = await _repo.unreadCount();
    notifyListeners();
  }

  Future<void> load() async {
    await paged.load();
    await refreshBadge();
  }

  Future<void> markAllRead() async {
    paged.replaceAll(
      paged.items.map((n) => n.copyWith(unread: false)).toList(),
    );
    _unread = 0;
    notifyListeners();
    await _repo.readAll();
  }

  Future<void> markRead(String id) async {
    paged.replaceAll(
      paged.items.map((n) => n.id == id ? n.copyWith(unread: false) : n).toList(),
    );
    _unread = paged.items.where((n) => n.unread).length;
    notifyListeners();
    await _repo.read(id);
  }

  void clear() {
    paged.replaceAll(const []);
    _unread = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    paged
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
