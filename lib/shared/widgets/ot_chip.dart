import 'package:flutter/material.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';

/// Qidiruv ekranidagi filtr chipi va ommabop so'rovlar chipi.
class OtChip extends StatelessWidget {
  const OtChip({
    super.key,
    required this.label,
    this.onTap,
    this.selected = false,
    this.trailing,
  });

  final String label;
  final VoidCallback? onTap;
  final bool selected;

  /// Tanlanganda × , tanlanmaganda ˅ ko'rsatish uchun
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? OtColors.accent : OtColors.ink;
    return Material(
      color: selected ? OtColors.accentSoft : OtColors.surface,
      borderRadius: BorderRadius.circular(OtSize.rPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OtSize.rPill),
        child: Ink(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(OtSize.rPill),
            border: Border.all(
              color: selected ? OtColors.accentLine : OtColors.lineStrong,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 5),
                Icon(trailing, size: 14, color: selected ? fg : OtColors.inkMuted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
