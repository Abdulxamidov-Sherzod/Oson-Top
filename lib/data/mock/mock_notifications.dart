import '../models/app_notification.dart';

final DateTime _now = DateTime.now();
DateTime _ago({int d = 0, int h = 0, int m = 0}) =>
    _now.subtract(Duration(days: d, hours: h, minutes: m));

final mockNotifications = <AppNotification>[
  AppNotification(
    id: 'n1',
    kind: NotificationKind.matchedSearch,
    title: 'Siz qidirgan iPhone 13 eʼloni joylandi',
    body: '4 500 000 soʻm · Fargʻona shahri',
    at: _ago(m: 12),
    unread: true,
  ),
  AppNotification(
    id: 'n2',
    kind: NotificationKind.approved,
    title: 'Eʼloningiz tasdiqlandi',
    body: 'Yumshoq burchak divan · Oltiariq',
    at: _ago(h: 1),
    unread: true,
  ),
  AppNotification(
    id: 'n3',
    kind: NotificationKind.priceDrop,
    title: 'Saqlangan eʼlon narxi oʻzgardi',
    body: 'Chevrolet Cobalt 2019 · 132 000 000 soʻm',
    at: _ago(d: 1, h: 6),
  ),
  AppNotification(
    id: 'n4',
    kind: NotificationKind.call,
    title: '2 marta qoʻngʻiroq qilishdi',
    body: 'Yumshoq burchak divan eʼloningiz boʻyicha',
    at: _ago(d: 1, h: 14),
  ),
  AppNotification(
    id: 'n5',
    kind: NotificationKind.expiring,
    title: 'Eʼlon muddati tugayapti',
    body: 'Samsung kir yuvish mashinasi — 3 kundan keyin arxivga tushadi',
    at: _ago(d: 2),
  ),
];
