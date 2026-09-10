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
                  ? const Center(
                      child: CircularProgressIndicator(color: OtColors.accent),
                    )
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
    return Container(
      padding: const EdgeInsets.fromLTRB(
          OtSize.screenPad, 10, OtSize.screenPad, 12),
      decoration: const BoxDecoration(
        color: OtColors.surface,
        border: Border(bottom: BorderSide(color: OtColors.lineFaint)),
      ),
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
