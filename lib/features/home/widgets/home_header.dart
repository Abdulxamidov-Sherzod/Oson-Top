import 'package:flutter/material.dart';
import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';
import '../../../shared/widgets/ot_logo.dart';
import '../../../core/lang.dart';

/// Logotip, joylashuv tanlash va bildirishnoma tugmasi.
/// Bildirishnoma tab EMAS — dizayn qarori, `CLAUDE.md` ga qarang.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.district,
    required this.unreadCount,
    required this.onDistrictTap,
    required this.onBellTap,
  });

  final String district;
  final int unreadCount;
  final VoidCallback onDistrictTap;
  final VoidCallback onBellTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _brand(),
        const SizedBox(width: 8),
        // Tugma o'z eniga qarab turadi, joy yetmasa matn qisqaradi
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _districtPill(),
          ),
        ),
        const SizedBox(width: 6),
        _bell(),
      ],
    );
  }

  /// Logo yozuvning o'zini o'z ichiga oladi, shuning uchun yonida
  /// "Oson Top" matni takrorlanmaydi.
  Widget _brand() => const OtLogo(height: 38);

  Widget _districtPill() {
    return GestureDetector(
      onTap: onDistrictTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: OtColors.field,
          borderRadius: BorderRadius.circular(OtSize.rPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.place_outlined, size: 13, color: OtColors.accent),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                tr(district),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: OtColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.expand_more, size: 14, color: OtColors.inkMuted),
          ],
        ),
      ),
    );
  }

  Widget _bell() {
    return GestureDetector(
      onTap: onBellTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: OtSize.minTap,
        height: OtSize.minTap,
        child: Center(
          child: SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: OtColors.field,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.notifications_none,
                      size: 20, color: OtColors.ink),
                ),
                if (unreadCount > 0)
                  Positioned(top: -5, right: -5, child: _badge()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge() {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: OtColors.danger,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: OtColors.surface, width: 2),
      ),
      child: Text(
        unreadCount > 9 ? '9+' : '$unreadCount',
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: OtColors.surface,
          height: 1,
        ),
      ),
    );
  }
}
