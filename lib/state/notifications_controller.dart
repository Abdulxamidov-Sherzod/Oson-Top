import 'package:flutter/foundation.dart';

import '../data/models/app_notification.dart';
import '../data/repositories/notifications_repository.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController(this._repo);

  final NotificationsRepository _repo;

  List<AppNotification> _items = const [];
  int _unread = 0;
  bool _loading = false;
  String? error;

  List<AppNotification> get items => _items;
  int get unreadCount => _unread;
  bool get isLoading => _loading;

  /// Bosh sahifadagi badge uchun — ro'yxatning o'zi kerak emas
  Future<void> refreshBadge() async {
    _unread = await _repo.unreadCount();
    notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    error = null;
    notifyListeners();
    try {
      _items = await _repo.list();
      _unread = _items.where((n) => n.unread).length;
    } catch (e) {
      error = '$e';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> markAllRead() async {
    _items = _items.map((n) => n.copyWith(unread: false)).toList();
    _unread = 0;
    notifyListeners();
    await _repo.readAll();
  }

  Future<void> markRead(String id) async {
    _items = _items
        .map((n) => n.id == id ? n.copyWith(unread: false) : n)
        .toList();
    _unread = _items.where((n) => n.unread).length;
    notifyListeners();
    await _repo.read(id);
  }

  void clear() {
    _items = const [];
    _unread = 0;
    notifyListeners();
  }
}
