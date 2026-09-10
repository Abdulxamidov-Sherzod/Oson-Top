import 'package:flutter/material.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../core/lang.dart';

enum OtButtonKind {
  /// Yashil, to'ldirilgan — asosiy harakat
  primary,

  /// Oq, chegarali — ikkilamchi harakat
  secondary,
}

class OtButton extends StatelessWidget {
  const OtButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = OtButtonKind.primary,
    this.icon,
    this.trailingIcon,
    this.large = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final OtButtonKind kind;
  final IconData? icon;
  final IconData? trailingIcon;

  /// 54px balandlik — forma pastidagi asosiy tugma uchun
  final bool large;

  bool get _primary => kind == OtButtonKind.primary;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fg = _primary ? OtColors.surface : OtColors.ink;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: _primary ? OtColors.accent : OtColors.surface,
        borderRadius: BorderRadius.circular(OtSize.rCard),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(OtSize.rCard),
          splashColor: _primary
              ? OtColors.accentPressed.withValues(alpha: 0.4)
              : OtColors.accentSoft,
          child: Ink(
            height: large ? OtSize.buttonLg : OtSize.button,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(OtSize.rCard),
              border: _primary
                  ? null
                  : Border.all(color: OtColors.lineField, width: 1.5),
              boxShadow: _primary && enabled
                  ? [
                      BoxShadow(
                        color: OtColors.accent.withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: 8),
                ],
                Text(
                  tr(label),
                  style: (_primary ? OtText.button : OtText.buttonGhost)
                      .copyWith(color: fg),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailingIcon, size: 17, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
