import 'package:flutter/material.dart';

import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';

/// Firibgarlikdan ogohlantirish. Har bir e'lon sahifasida bo'ladi —
/// bu ilovaning majburiy qismi, `CLAUDE.md` ga qarang.
class SafetyNote extends StatelessWidget {
  const SafetyNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: OtColors.warnBg,
        borderRadius: BorderRadius.circular(OtSize.rCard),
        border: Border.all(color: OtColors.warnLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.warning_amber_rounded,
                size: 18, color: OtColors.warnIcon),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: OtColors.warnInk,
                ),
                children: [
                  TextSpan(
                    text: 'Ehtiyot boʻling. ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: OtColors.warnInkStrong,
                    ),
                  ),
                  TextSpan(
                    text: 'Oldindan pul oʻtkazmang. Mahsulotni koʻrmasdan '
                        'kartaga toʻlov qilmang — kelishuv joyida boʻlsin.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
