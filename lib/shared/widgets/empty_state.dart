import 'package:flutter/material.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_text.dart';
import 'ot_button.dart';

/// Bo'sh ro'yxat holati — bildirishnomalar, saqlanganlar, qidiruv natijasi.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: OtColors.field,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: OtColors.inkFaint),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: OtText.bodyStrong.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: OtText.body.copyWith(
                color: OtColors.inkMuted,
                fontSize: 13.5,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              IntrinsicWidth(
                child: OtButton(
                  label: actionLabel!,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
