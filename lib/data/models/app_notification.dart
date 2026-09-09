enum NotificationKind {
  /// Qidiruvingizga mos yangi e'lon
  matchedSearch,

  /// Saqlangan e'lon narxi o'zgardi
  priceDrop,

  /// E'loningiz tasdiqlandi
  approved,

  /// Sizning e'loningizga qo'ng'iroq bo'ldi
  call,

  /// E'lon muddati tugayapti
  expiring,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.at,
    this.unread = false,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime at;
  final bool unread;

  AppNotification copyWith({bool? unread}) => AppNotification(
        id: id, kind: kind, title: title, body: body, at: at,
        unread: unread ?? this.unread,
      );
}
