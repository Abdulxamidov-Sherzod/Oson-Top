import 'package:flutter/material.dart';
import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';
import '../../../data/models/category.dart';
import '../../../core/lang.dart';

/// Gorizontal kategoriya ro'yxati. Tanlangan kategoriyani qayta bosish
/// filtrni bekor qiladi.
class CategoryRail extends StatelessWidget {
  const CategoryRail({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: OtSize.screenPad),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _item(categories[i]),
      ),
    );
  }

  Widget _item(Category c) {
    final active = c.id == selectedId;
    return GestureDetector(
      onTap: () => onSelect(c.id),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        // Ikonka 58px, lekin nom kengroq joy talab qiladi: kirillcha va
        // ruscha lotinchadan uzun ("Недвижимость"), tor katakda esa
        // so'z o'rtasidan bo'linib ketardi.
        width: 74,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: active ? OtColors.accent : OtColors.accentSoft,
                borderRadius: BorderRadius.circular(19),
              ),
              child: Icon(
                c.icon,
                size: 24,
                color: active ? OtColors.surface : OtColors.accent,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              tr(c.label),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.2,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? OtColors.accent : OtColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
