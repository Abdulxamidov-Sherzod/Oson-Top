import 'package:flutter/foundation.dart';
import '../data/mock/mock_notifications.dart';
import '../data/models/app_notification.dart';

/// Bildirishnomalar. Bosh sahifadagi badge soni shu yerdan olinadi.
/// To'liq ekran 6-qismda quriladi.
class NotificationsController extends ChangeNotifier {
  NotificationsController() : _items = List.of(mockNotifications);

  List<AppNotification> _items;

  List<AppNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => n.unread).length;

  void markAllRead() {
    _items = _items.map((n) => n.copyWith(unread: false)).toList();
    notifyListeners();
  }

  void markRead(String id) {
    _items = _items
        .map((n) => n.id == id ? n.copyWith(unread: false) : n)
        .toList();
    notifyListeners();
  }
}
