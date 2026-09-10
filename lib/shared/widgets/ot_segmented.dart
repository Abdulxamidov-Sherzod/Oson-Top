import 'package:flutter/material.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/lang.dart';

/// Ikki yoki uch variantli tanlov — "Yangi / Ishlatilgan",
/// "Eng yangi / Arzonidan / Qimmatidan".
class OtSegmented<T> extends StatelessWidget {
  const OtSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  /// Tartib muhim — ekranda shu ketma-ketlikda chiqadi
  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: OtColors.field,
        borderRadius: BorderRadius.circular(OtSize.rMd),
      ),
      child: Row(
        children: [
          for (final entry in options.entries)
            Expanded(child: _segment(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _segment(T key, String label) {
    final active = key == value;
    return GestureDetector(
      onTap: () => onChanged(key),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? OtColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(OtSize.rSm),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: OtColors.liftShadow,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          tr(label),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: active ? OtColors.ink : OtColors.inkMuted,
          ),
        ),
      ),
    );
  }
}
