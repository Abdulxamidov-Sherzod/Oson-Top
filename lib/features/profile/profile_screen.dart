import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/mock/mock_user.dart';
import '../../state/favorites_controller.dart';
import '../../state/notifications_controller.dart';
import '../dev/component_gallery_screen.dart';
import 'favorites_screen.dart';
import 'my_listings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesController>();
    final unread = context.select<NotificationsController, int>(
      (n) => n.unreadCount,
    );

    return Material(
      color: OtColors.ground,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              OtSize.screenPad, 10, OtSize.screenPad, OtSize.x24),
          children: [
            Text('Profil', style: OtText.display),
            const SizedBox(height: OtSize.x20),
            _identity(),
            const SizedBox(height: OtSize.x16),
            _stats(favorites.count),
            const SizedBox(height: OtSize.x20),
            _menu(context, favorites.count, unread),
            const SizedBox(height: OtSize.x20),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Chiqish',
                  style: OtText.bodyStrong.copyWith(color: OtColors.inkMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _identity() {
    return Row(
      children: [
        Container(
          width: 62,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: OtColors.accentTint,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            mockUser.initials,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: OtColors.accentPressed,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mockUser.name,
                  style: OtText.titleSm.copyWith(fontSize: 18)),
              const SizedBox(height: 3),
              Text(mockUser.phone, style: OtText.metaMd),
              const SizedBox(height: 2),
              Text(
                '${mockUser.district} · '
                '${OtFormat.memberSince(mockUser.memberSince)}',
                style: OtText.metaSm,
              ),
            ],
          ),
        ),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: OtColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: OtColors.line),
          ),
          child: const Icon(Icons.edit_outlined,
              size: 16, color: OtColors.inkMuted),
        ),
      ],
    );
  }

  Widget _stats(int saved) {
    Widget tile(String value, String label) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: OtColors.surface,
              borderRadius: BorderRadius.circular(OtSize.rCard),
              border: Border.all(color: OtColors.line),
            ),
            child: Column(
              children: [
                Text(value, style: OtText.titleSm.copyWith(fontSize: 20)),
                const SizedBox(height: 3),
                Text(label, style: OtText.metaSm),
              ],
            ),
          ),
        );

    return Row(
      children: [
        tile('${mockUser.activeListings}', 'Aktiv eʼlon'),
        const SizedBox(width: 10),
        tile(OtFormat.number(mockUser.totalViews), 'Koʻrishlar'),
        const SizedBox(width: 10),
        tile('$saved', 'Saqlanganlar'),
      ],
    );
  }

  Widget _menu(BuildContext context, int saved, int unread) {
    return Container(
      decoration: BoxDecoration(
        color: OtColors.surface,
        borderRadius: BorderRadius.circular(OtSize.rCard),
        border: Border.all(color: OtColors.line),
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.inventory_2_outlined,
            label: 'Mening eʼlonlarim',
            trailing: '${mockUser.activeListings}',
            onTap: () => _push(context, const MyListingsScreen()),
          ),
          _MenuTile(
            icon: Icons.favorite_border,
            label: 'Saqlangan eʼlonlar',
            trailing: '$saved',
            onTap: () => _push(context, const FavoritesScreen()),
          ),
          _MenuTile(
            icon: Icons.chat_bubble_outline,
            label: 'Xabarlar',
            badge: unread,
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.tune,
            label: 'Sozlamalar',
            onTap: () {},
          ),
          // 0-qismdan qolgan: poydevor tugagach olib tashlanadi
          _MenuTile(
            icon: Icons.widgets_outlined,
            label: 'Komponentlar',
            last: true,
            onTap: () => _push(context, const ComponentGalleryScreen()),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => screen));
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.badge,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final int? badge;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: OtColors.lineFaint)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: OtColors.accentSoft,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: OtColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: OtText.bodyStrong)),
            if (badge != null && badge! > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: OtColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: OtColors.surface,
                  ),
                ),
              )
            else if (trailing != null)
              Text(trailing!, style: OtText.metaSm),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                size: 20, color: OtColors.dividerDot),
          ],
        ),
      ),
    );
  }
}
