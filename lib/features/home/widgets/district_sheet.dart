import 'package:flutter/material.dart';
import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';
import '../../../core/theme/ot_text.dart';
import '../../../data/mock/mock_districts.dart';

/// Joylashuv tanlash oynasi. Farg'ona viloyatining shahar va tumanlari.
Future<String?> showDistrictSheet(BuildContext context, String current) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: OtColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(OtSize.rSheet)),
    ),
    builder: (_) => _DistrictSheet(current: current),
  );
}

class _DistrictSheet extends StatelessWidget {
  const _DistrictSheet({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    final options = [allDistricts, ...mockDistricts];

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: OtColors.lineField,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  OtSize.screenPad, 16, OtSize.screenPad, 10),
              child: Row(
                children: [
                  Text('Joylashuv', style: OtText.display),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: options.length,
                itemBuilder: (_, i) => _row(context, options[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String value) {
    final selected = value == current;
    return InkWell(
      onTap: () => Navigator.of(context).pop(value),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: OtSize.screenPad),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: OtText.bodyStrong.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? OtColors.accent : OtColors.ink,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 20, color: OtColors.accent),
          ],
        ),
      ),
    );
  }
}
