import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';
import '../../../core/theme/ot_text.dart';

/// Bosilganda tanlov oynasi ochiladigan maydon — kategoriya, tuman.
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: OtText.label),
        const SizedBox(height: 7),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: OtSize.field,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: OtColors.field,
              borderRadius: BorderRadius.circular(OtSize.rMd),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: OtColors.accent),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, color: OtColors.ink),
                  ),
                ),
                const Icon(Icons.expand_more,
                    size: 18, color: OtColors.inkMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Narx maydoni: yozilganda 3 200 000 shaklida formatlanadi,
/// "kelishiladi" belgilansa o'chadi.
class PriceField extends StatefulWidget {
  const PriceField({
    super.key,
    required this.negotiable,
    required this.onPriceChanged,
    required this.onNegotiableChanged,
    this.error,
  });

  final bool negotiable;
  final ValueChanged<int?> onPriceChanged;
  final ValueChanged<bool> onNegotiableChanged;
  final String? error;

  @override
  State<PriceField> createState() => _PriceFieldState();
}

class _PriceFieldState extends State<PriceField> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    final digits = v.replaceAll(RegExp(r'\D'), '');
    final text = digits.isEmpty ? '' : OtFormat.number(int.parse(digits));
    _c.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    widget.onPriceChanged(digits.isEmpty ? null : int.parse(digits));
  }

  @override
  Widget build(BuildContext context) {
    final off = widget.negotiable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Narx', style: OtText.label),
        const SizedBox(height: 7),
        Opacity(
          opacity: off ? 0.45 : 1,
          child: Container(
            height: OtSize.field,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: OtColors.field,
              borderRadius: BorderRadius.circular(OtSize.rMd),
              border: widget.error != null
                  ? Border.all(color: OtColors.danger)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _c,
                    enabled: !off,
                    keyboardType: TextInputType.number,
                    cursorColor: OtColors.accent,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: OtColors.ink),
                    onChanged: _onChanged,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle:
                          TextStyle(fontSize: 15, color: OtColors.inkFaint),
                    ),
                  ),
                ),
                const Text('soʻm', style: OtText.metaSm),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            if (!off) _c.clear();
            widget.onNegotiableChanged(!off);
          },
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: OtSize.minTap,
            child: Row(
              children: [
                Icon(
                  off ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 22,
                  color: off ? OtColors.accent : OtColors.inkFaint,
                ),
                const SizedBox(width: 10),
                const Text('Narx kelishiladi',
                    style: TextStyle(fontSize: 14.5, color: OtColors.ink)),
              ],
            ),
          ),
        ),
        if (widget.error != null)
          Text(
            widget.error!,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: OtColors.danger,
            ),
          ),
      ],
    );
  }
}
