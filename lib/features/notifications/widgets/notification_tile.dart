import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';
import '../../../core/theme/ot_text.dart';
import '../../../data/models/app_notification.dart';
import '../../../core/lang.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item, this.onTap});

  final AppNotification item;
  final VoidCallback? onTap;

  /// Har bir turga o'z ikonasi va rangi
  (IconData, Color, Color) get _look => switch (item.kind) {
        NotificationKind.matchedSearch =>
          (Icons.search, OtColors.accentPressed, OtColors.accentTint),
        NotificationKind.approved =>
          (Icons.check_rounded, OtColors.accentPressed, OtColors.accentTint),
        NotificationKind.rejected =>
          (Icons.error_outline, OtColors.danger, Color(0xFFFDECEC)),
        NotificationKind.priceDrop =>
          (Icons.trending_down, OtColors.warnIcon, OtColors.warnBg),
        NotificationKind.call =>
          (Icons.call_outlined, OtColors.inkMuted, OtColors.field),
        NotificationKind.expiring =>
          (Icons.schedule, OtColors.warnIcon, OtColors.warnBg),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, fg, bg) = _look;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.unread ? OtColors.accentSofter : OtColors.surface,
          borderRadius: BorderRadius.circular(OtSize.rLg),
          border: Border.all(
            color: item.unread ? OtColors.accentLine : OtColors.line,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(OtSize.rMd),
              ),
              child: Icon(icon, size: 19, color: fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: OtColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(item.body, style: OtText.metaMd.copyWith(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(tr(OtFormat.timeAgo(item.at)), style: OtText.metaSm),
                ],
              ),
            ),
            if (item.unread)
              Container(
                margin: const EdgeInsets.only(left: 10, top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: OtColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
