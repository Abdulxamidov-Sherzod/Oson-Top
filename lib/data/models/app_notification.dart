enum NotificationKind {
  /// Moderator e'lonni qaytardi — sababi `body` da
  rejected,

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

  /// Adminkadan yuborilgan xabar
  announcement,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.at,
    this.unread = false,
    this.listingId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: '${json['id']}',
        kind: _kind(json['kind'] as String?),
        title: json['title'] as String,
        body: json['body'] as String? ?? '',
        at: DateTime.parse(json['created_at'] as String).toLocal(),
        unread: json['unread'] as bool? ?? false,
        listingId: json['listing_id'] == null ? null : '${json['listing_id']}',
      );

  static NotificationKind _kind(String? raw) => switch (raw) {
        'matched_search' => NotificationKind.matchedSearch,
        'price_drop' => NotificationKind.priceDrop,
        'approved' => NotificationKind.approved,
        'rejected' => NotificationKind.rejected,
        'call' => NotificationKind.call,
        'announcement' => NotificationKind.announcement,
        _ => NotificationKind.expiring,
      };

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime at;
  final bool unread;

  /// Bosilganda ochiladigan e'lon — bo'lmasligi mumkin
  final String? listingId;

  AppNotification copyWith({bool? unread}) => AppNotification(
        id: id, kind: kind, title: title, body: body, at: at,
        listingId: listingId,
        unread: unread ?? this.unread,
      );
}
