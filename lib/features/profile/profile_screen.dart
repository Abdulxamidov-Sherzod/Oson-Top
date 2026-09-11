import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/lang.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/models/app_user.dart';
import '../../state/auth_controller.dart';
import '../../state/favorites_controller.dart';
import '../../state/notifications_controller.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/ot_button.dart';
import '../auth/login_screen.dart';
import 'favorites_screen.dart';
import 'my_listings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final favorites = context.watch<FavoritesController>();

    final user = auth.user;
    if (user == null) return const _SignedOutProfile();

    return Material(
      color: OtColors.ground,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              OtSize.screenPad, 10, OtSize.screenPad, OtSize.x24),
          children: [
            Text(tr('Profil'), style: OtText.display),
            const SizedBox(height: OtSize.x20),
            _identity(user),
            const SizedBox(height: OtSize.x16),
            _stats(user, favorites.count),
            const SizedBox(height: OtSize.x20),
            _menu(context, user, favorites.count),
            const SizedBox(height: OtSize.x20),
            Center(
              child: TextButton(
                onPressed: () => _signOut(context),
                child: Text(
                  tr('Chiqish'),
                  style: OtText.bodyStrong.copyWith(color: OtColors.inkMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _identity(AppUser user) {
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
            user.initials,
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
              Text(user.name,
                  style: OtText.titleSm.copyWith(fontSize: 18)),
              const SizedBox(height: 3),
              Text(user.phone, style: OtText.metaMd),
              const SizedBox(height: 2),
              Text(
                tr('${user.district} · ${OtFormat.memberSince(user.memberSince)}'),
                style: OtText.metaSm,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stats(AppUser user, int saved) {
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
                Text(tr(label), style: OtText.metaSm),
              ],
            ),
          ),
        );

    return Row(
      children: [
        tile('${user.activeListings}', 'Aktiv eʼlon'),
        const SizedBox(width: 10),
        tile(OtFormat.number(user.totalViews), 'Koʻrishlar'),
        const SizedBox(width: 10),
        tile('$saved', 'Saqlanganlar'),
      ],
    );
  }

  Widget _menu(BuildContext context, AppUser user, int saved) {
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
            label: tr('Mening eʼlonlarim'),
            trailing: '${user.totalListings}',
            onTap: () => _push(context, const MyListingsScreen()),
          ),
          _MenuTile(
            icon: Icons.favorite_border,
            label: tr('Saqlangan eʼlonlar'),
            trailing: '$saved',
            onTap: () => _push(context, const FavoritesScreen()),
          ),
          _MenuTile(
            icon: Icons.language,
            label: tr('Til'),
            trailing: otLang.label,
            last: true,
            onTap: () => pickLang(context),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => screen));


  Future<void> _signOut(BuildContext context) async {
    // Chiqish bir bosishda boʻlmasin — qaytadan kirish uchun Telegram kerak
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: OtColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OtSize.rLg),
        ),
        title: Text(tr('Chiqasizmi?'), style: OtText.titleSm),
        content: Text(
          tr('Qaytadan kirish uchun Telegram orqali tasdiqlash kerak boʻladi.'),
          style: OtText.body.copyWith(color: OtColors.inkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(tr('Bekor qilish'),
                style: OtText.body.copyWith(color: OtColors.inkMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(tr('Chiqish'),
                style: OtText.bodyStrong.copyWith(color: OtColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final auth = context.read<AuthController>();
    final favorites = context.read<FavoritesController>();
    final notifications = context.read<NotificationsController>();

    await auth.signOut();
    favorites.clear();
    notifications.clear();
  }
}

/// Kirmagan foydalanuvchi uchun — lentani ko'rish mumkin, profil yo'q
class _SignedOutProfile extends StatelessWidget {
  const _SignedOutProfile();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OtColors.ground,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(OtSize.screenPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('Profil'), style: OtText.display),
              const Spacer(),
              EmptyState(
                icon: Icons.person_outline,
                title: tr('Hali kirmadingiz'),
                body: tr('Eʼlon berish va saqlash uchun Telegram orqali kiring.'),
              ),
              const SizedBox(height: OtSize.x16),
              SizedBox(
                width: double.infinity,
                child: OtButton(
                  label: tr('Telegram orqali kirish'),
                  icon: Icons.send_outlined,
                  large: true,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                ),
              ),
              const SizedBox(height: OtSize.x12),
              // Til kirmasdan ham almashtiriladi
              Center(
                child: TextButton.icon(
                  onPressed: () => pickLang(context),
                  icon: const Icon(Icons.language,
                      size: 18, color: OtColors.inkMuted),
                  label: Text(otLang.label, style: OtText.metaMd),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> pickLang(BuildContext context) async {
  final controller = context.read<LangController>();

  final picked = await showModalBottomSheet<OtLang>(
    context: context,
    backgroundColor: OtColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(OtSize.rSheet)),
    ),
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: OtSize.x12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: OtColors.lineField,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: OtSize.x16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: OtSize.screenPad),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(tr('Til'), style: OtText.titleSm),
            ),
          ),
          const SizedBox(height: OtSize.x8),
          for (final lang in OtLang.values)
            ListTile(
              // Nom o'z alifbosida yozilgan, shuning uchun tr() qo'llanmaydi
              title: Text(lang.label, style: OtText.body),
              trailing: lang == otLang
                  ? const Icon(Icons.check, color: OtColors.accent, size: 20)
                  : null,
              onTap: () => Navigator.of(sheet).pop(lang),
            ),
          const SizedBox(height: OtSize.x8),
        ],
      ),
    ),
  );

  if (picked != null) await controller.set(picked);
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
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
            Expanded(child: Text(tr(label), style: OtText.bodyStrong)),
            if (trailing != null)
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
