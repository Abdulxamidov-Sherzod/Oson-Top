import 'package:flutter/material.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';

/// Formadagi maydon: yorliq + input + ixtiyoriy izoh yoki xato.
class OtTextField extends StatelessWidget {
  const OtTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.error,
    this.optional = false,
    this.multiline = false,
    this.keyboardType,
    this.maxLength,
    this.suffix,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final String? error;

  /// Yorliq yoniga "· ixtiyoriy" qo'shadi
  final bool optional;

  final bool multiline;
  final TextInputType? keyboardType;
  final int? maxLength;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: OtText.label,
            children: [
              TextSpan(text: label),
              if (optional)
                const TextSpan(
                  text: ' · ixtiyoriy',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: OtColors.inkFaint,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Container(
          constraints: BoxConstraints(
            minHeight: multiline ? 82 : OtSize.field,
          ),
          decoration: BoxDecoration(
            color: OtColors.field,
            borderRadius: BorderRadius.circular(OtSize.rMd),
            border: hasError ? Border.all(color: OtColors.danger) : null,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: multiline ? 12 : 0,
          ),
          child: Row(
            crossAxisAlignment:
                multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: keyboardType ??
                      (multiline ? TextInputType.multiline : null),
                  maxLines: multiline ? null : 1,
                  minLines: multiline ? 3 : null,
                  maxLength: maxLength,
                  style: const TextStyle(fontSize: 15, color: OtColors.ink),
                  cursorColor: OtColors.accent,
                  decoration: InputDecoration(
                    isDense: true,
                    counterText: '',
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      color: OtColors.inkFaint,
                    ),
                  ),
                ),
              ),
              if (suffix != null) ...[const SizedBox(width: 8), suffix!],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: OtColors.danger,
            ),
          ),
        ] else if (helper != null) ...[
          const SizedBox(height: 6),
          Text(helper!, style: OtText.metaSm),
        ],
      ],
    );
  }
}
