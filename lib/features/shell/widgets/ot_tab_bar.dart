import 'package:flutter/material.dart';
import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';
import '../../../core/theme/ot_text.dart';

/// Pastdagi 3 ta tab. Qidiruv va Bildirishnoma bu yerda YO'Q —
/// ular bosh sahifadan ochiladi (dizayn qarori, `CLAUDE.md` ga qarang).
class OtTabBar extends StatelessWidget {
  const OtTabBar({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: OtColors.surface,
        border: Border(top: BorderSide(color: OtColors.line)),
      ),
      padding: EdgeInsets.only(top: 9, left: 6, right: 6, bottom: bottomInset),
      child: SizedBox(
        height: OtSize.tabBar - 9 - 22,
        child: Row(
          children: [
            _tab(0, Icons.home_outlined, 'Bosh sahifa'),
            _postTab(1),
            _tab(2, Icons.person_outline, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _tab(int i, IconData icon, String label) {
    final active = index == i;
    final color = active ? OtColors.accent : OtColors.inkInactive;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(i),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(label, style: OtText.tab.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  /// "E'lon berish" — yashil tugmacha bilan, dizayndagidek
  Widget _postTab(int i) {
    final active = index == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(i),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 28,
              decoration: BoxDecoration(
                color: OtColors.accent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: OtColors.accent.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.add, size: 18, color: OtColors.surface),
            ),
            const SizedBox(height: 4),
            Text(
              'Eʼlon berish',
              style: OtText.tab.copyWith(
                color: active ? OtColors.accent : OtColors.inkInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
