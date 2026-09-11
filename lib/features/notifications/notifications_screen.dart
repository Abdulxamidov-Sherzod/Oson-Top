import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/async_value.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/load_more.dart';
import '../../state/auth_controller.dart';
import '../../state/notifications_controller.dart';
import '../auth/login_screen.dart';
import 'widgets/notification_tile.dart';
import '../../core/lang.dart';
import '../../shared/widgets/ot_shimmer.dart';
import '../../shared/widgets/ot_empty_art.dart';

/// Bosh sahifadagi qo'ng'iroqchadan ochiladi — tab emas.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    attachLoadMore(
      _scroll,
      () => context.read<NotificationsController>().paged.loadMore(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Kirmagan odamda bildirishnoma bo'lmaydi — so'rov ham yubormaymiz
      if (context.read<AuthController>().isSignedIn) {
        context.read<NotificationsController>().load();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationsController>();
    final signedIn = context.watch<AuthController>().isSignedIn;
    final items = controller.items;

    return Scaffold(
      backgroundColor: OtColors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context, controller),
            Expanded(
              child: !signedIn
                  ? EmptyState(
                      icon: Icons.notifications_none,
                      art: OtEmptyArt.bell,
                      title: tr('Kirmagansiz'),
                      body: tr('Eʼloningiz tasdiqlanganda yoki xaridor bogʻlanganda shu yerda xabar chiqadi.'),
                      actionLabel: tr('Telegram orqali kirish'),
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      ),
                    )
                  : controller.paged.state.isLoading && items.isEmpty
                  ? const _TileSkeleton()
                  : controller.paged.state is AsyncError && items.isEmpty
                  ? EmptyState(
                      icon: Icons.cloud_off,
                      title: tr('Yuklab boʻlmadi'),
                      body: (controller.paged.state as AsyncError).message,
                      actionLabel: 'Qaytadan',
                      onAction: controller.load,
                    )
                  : items.isEmpty
                  ? EmptyState(
                      icon: Icons.notifications_none,
                      art: OtEmptyArt.bell,
                      title: tr('Bildirishnomalar yoʻq'),
                      body: tr('Qidiruvni saqlab qoʻysangiz, mos eʼlon chiqqanda birinchi boʻlib xabar beramiz.'),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(14, OtSize.x12, 14, 0),
                      itemCount: items.length + 1,
                      itemBuilder: (_, i) => i == items.length
                          ? LoadMoreFooter(paged: controller.paged)
                          : NotificationTile(
                              item: items[i],
                              onTap: () => controller.markRead(items[i].id),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, NotificationsController c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          OtSize.screenPad, 10, OtSize.screenPad, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 36,
              height: OtSize.minTap,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.arrow_back_ios_new,
                    size: 20, color: OtColors.ink),
              ),
            ),
          ),
          Expanded(child: Text(tr('Bildirishnomalar'), style: OtText.display)),
          if (c.unreadCount > 0)
            GestureDetector(
              onTap: c.markAllRead,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Text(tr('Oʻqildi'), style: OtText.link),
              ),
            ),
        ],
      ),
    );
  }
}


/// Bildirishnomalar ro'yxatining yuklanayotgandagi shakli.
class _TileSkeleton extends StatelessWidget {
  const _TileSkeleton();

  @override
  Widget build(BuildContext context) {
    return OtShimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            OtSize.screenPad, OtSize.x8, OtSize.screenPad, OtSize.x24),
        itemCount: 6,
        itemBuilder: (_, _) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: OtColors.surface,
            borderRadius: BorderRadius.circular(OtSize.rLg),
            border: Border.all(color: OtColors.line),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OtSkeleton(width: 40, height: 40, radius: 13),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OtSkeleton(height: 13),
                    SizedBox(height: 7),
                    OtSkeleton(width: 150, height: 11),
                    SizedBox(height: 7),
                    OtSkeleton(width: 84, height: 9),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
