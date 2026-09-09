import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';
import '../../../core/theme/ot_text.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/reference_repository.dart';
import '../../../data/models/listing.dart';
import '../../../shared/widgets/ot_button.dart';
import '../search_controller.dart';

/// Filtr oynalarining umumiy qobig'i: tutqich, sarlavha, tarkib.
Future<T?> _sheet<T>(BuildContext context, String title, Widget body) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: OtColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(OtSize.rSheet)),
    ),
    builder: (_) => SafeArea(
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
              child: Row(children: [Text(title, style: OtText.display)]),
            ),
            Flexible(child: body),
          ],
        ),
      ),
    ),
  );
}

/// Tanlov qatori: nomi + belgisi
Widget _option(
  BuildContext context, {
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: OtSize.screenPad),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: OtText.bodyStrong.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? OtColors.accent : OtColors.ink,
              ),
            ),
          ),
          if (selected) const Icon(Icons.check, size: 20, color: OtColors.accent),
        ],
      ),
    ),
  );
}

/// Kategoriya tanlash. null qaytsa — "Barcha kategoriyalar".
Future<String?> showCategoryFilter(BuildContext context, String? current) {
  final categories = context.read<ReferenceRepository>().cachedCategories;
  return _sheet<String?>(
    context,
    'Kategoriya',
    ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _option(
          context,
          label: 'Barcha kategoriyalar',
          selected: current == null,
          onTap: () => Navigator.of(context).pop(null),
        ),
        for (final c in categories)
          _option(
            context,
            label: c.label,
            selected: c.id == current,
            onTap: () => Navigator.of(context).pop(c.id),
          ),
      ],
    ),
  );
}

/// Holat tanlash. Natija `_ConditionPick` ichida — null ham qiymat bo'lgani uchun.
class ConditionPick {
  const ConditionPick(this.value);
  final ListingCondition? value;
}

Future<ConditionPick?> showConditionFilter(
    BuildContext context, ListingCondition? current) {
  return _sheet<ConditionPick>(
    context,
    'Holati',
    ListView(
      padding: const EdgeInsets.only(bottom: 12),
      shrinkWrap: true,
      children: [
        _option(
          context,
          label: 'Farqi yoʻq',
          selected: current == null,
          onTap: () => Navigator.of(context).pop(const ConditionPick(null)),
        ),
        for (final c in [ListingCondition.fresh, ListingCondition.used])
          _option(
            context,
            label: c.label,
            selected: c == current,
            onTap: () => Navigator.of(context).pop(ConditionPick(c)),
          ),
      ],
    ),
  );
}

/// Narx oralig'i
Future<PriceRange?> showPriceFilter(BuildContext context, PriceRange current) {
  return _sheet<PriceRange>(
    context,
    'Narx',
    _PriceBody(current: current),
  );
}

class _PriceBody extends StatefulWidget {
  const _PriceBody({required this.current});
  final PriceRange current;

  @override
  State<_PriceBody> createState() => _PriceBodyState();
}

class _PriceBodyState extends State<_PriceBody> {
  late final _min = TextEditingController(
    text: widget.current.min == null ? '' : OtFormat.number(widget.current.min!),
  );
  late final _max = TextEditingController(
    text: widget.current.max == null ? '' : OtFormat.number(widget.current.max!),
  );

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  int? _parse(TextEditingController c) {
    final digits = c.text.replaceAll(RegExp(r'\D'), '');
    return digits.isEmpty ? null : int.parse(digits);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        OtSize.screenPad,
        4,
        OtSize.screenPad,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _field(_min, 'dan')),
              const SizedBox(width: 10),
              Expanded(child: _field(_max, 'gacha')),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Bittasini boʻsh qoldirsangiz ham boʻladi.',
            style: OtText.metaSm,
          ),
          const SizedBox(height: OtSize.x20),
          Row(
            children: [
              Expanded(
                child: OtButton(
                  label: 'Tozalash',
                  kind: OtButtonKind.secondary,
                  onPressed: () =>
                      Navigator.of(context).pop(const PriceRange()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: OtButton(
                  label: 'Qoʻllash',
                  onPressed: () => Navigator.of(context).pop(
                    PriceRange(min: _parse(_min), max: _parse(_max)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String hint) {
    return Container(
      height: OtSize.field,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: OtColors.field,
        borderRadius: BorderRadius.circular(OtSize.rMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: c,
              keyboardType: TextInputType.number,
              cursorColor: OtColors.accent,
              style: const TextStyle(fontSize: 15, color: OtColors.ink),
              onChanged: (v) {
                final digits = v.replaceAll(RegExp(r'\D'), '');
                final text = digits.isEmpty
                    ? ''
                    : OtFormat.number(int.parse(digits));
                c.value = TextEditingValue(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
              },
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 15, color: OtColors.inkFaint),
              ),
            ),
          ),
          const Text('soʻm', style: OtText.metaSm),
        ],
      ),
    );
  }
}
