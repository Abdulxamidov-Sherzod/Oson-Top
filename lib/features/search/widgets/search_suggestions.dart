import 'package:flutter/material.dart';

import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';
import '../../../core/theme/ot_text.dart';
import '../../../shared/widgets/ot_chip.dart';
import '../../../core/lang.dart';

/// Qidiruv maydoni bo'sh bo'lganda ko'rinadi: so'nggi va ommabop so'rovlar.
class SearchSuggestions extends StatelessWidget {
  const SearchSuggestions({
    super.key,
    required this.recent,
    required this.onPick,
    required this.onRemove,
    required this.onClearAll,
  });

  final List<String> recent;
  final ValueChanged<String> onPick;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  /// Farg'onada eng ko'p qidiriladigan so'rovlar
  static const popular = <String>[
    'Nexia 3',
    'Ijaraga uy Fargʻona',
    'Rishton keramika',
    'Redmi Note 13',
    'Margʻilon atlas',
    'Sotuvchi kerak',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          OtSize.screenPad, OtSize.x16, OtSize.screenPad, OtSize.x24),
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(tr('Soʻnggi qidiruvlar'), style: OtText.section),
              ),
              GestureDetector(
                onTap: onClearAll,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(tr('Tozalash'), style: OtText.link),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final q in recent) _recentRow(q),
          const SizedBox(height: OtSize.x20),
        ],
        Text(tr('Koʻp qidiriladigan'), style: OtText.section),
        const SizedBox(height: OtSize.x12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final q in popular)
              OtChip(label: q, onTap: () => onPick(q)),
          ],
        ),
      ],
    );
  }

  Widget _recentRow(String q) {
    return InkWell(
      onTap: () => onPick(q),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            const Icon(Icons.history, size: 18, color: OtColors.inkFaint),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                q,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, color: OtColors.ink),
              ),
            ),
            GestureDetector(
              onTap: () => onRemove(q),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: OtSize.minTap,
                height: OtSize.minTap,
                child: Icon(Icons.close, size: 17, color: OtColors.inkFaint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
