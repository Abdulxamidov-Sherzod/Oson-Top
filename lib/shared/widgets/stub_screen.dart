import 'package:flutter/material.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';

/// Vaqtinchalik ekran. 0-qismda navigatsiyani sinash uchun — har bir
/// ekran o'z qismida shu widget o'rniga haqiqiy kod bilan almashtiriladi.
class StubScreen extends StatelessWidget {
  const StubScreen({super.key, required this.title, required this.part});

  final String title;

  /// Qaysi qismda quriladi, masalan "1-qism"
  final String part;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(OtSize.screenPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(title, style: OtText.display),
            const SizedBox(height: OtSize.x12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: OtColors.fieldSoft,
                borderRadius: BorderRadius.circular(OtSize.rMd),
                border: Border.all(color: OtColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.construction_outlined,
                      size: 18, color: OtColors.inkFaint),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$part da quriladi',
                      style: OtText.body.copyWith(color: OtColors.inkMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
