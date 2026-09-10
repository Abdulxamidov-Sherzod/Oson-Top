import 'package:flutter/material.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../core/lang.dart';

/// Joylashuv tanlash oynasi. Farg'ona viloyatining shahar va tumanlari.
/// Barcha tumanlar varianti — filtrni bekor qilish uchun
const allDistrictsLabel = 'Fargʻona viloyati';

Future<String?> showDistrictSheet(
  BuildContext context,
  String current,
  List<String> districts,
) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: OtColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(OtSize.rSheet)),
    ),
    builder: (_) => _DistrictSheet(current: current, districts: districts),
  );
}

class _DistrictSheet extends StatelessWidget {
  const _DistrictSheet({required this.current, required this.districts});

  final String current;
  final List<String> districts;

  @override
  Widget build(BuildContext context) {
    final options = [allDistrictsLabel, ...districts];

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
                  Text(tr('Joylashuv'), style: OtText.display),
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
