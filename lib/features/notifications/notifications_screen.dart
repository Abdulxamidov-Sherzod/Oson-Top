import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../shared/widgets/empty_state.dart';
import '../../state/notifications_controller.dart';
import 'widgets/notification_tile.dart';

/// Bosh sahifadagi qo'ng'iroqchadan ochiladi — tab emas.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<NotificationsController>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationsController>();
    final items = controller.items;

    return Scaffold(
      backgroundColor: OtColors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context, controller),
            Expanded(
              child: controller.isLoading && items.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: OtColors.accent),
                    )
                  : controller.error != null && items.isEmpty
                  ? EmptyState(
                      icon: Icons.cloud_off,
                      title: 'Yuklab boʻlmadi',
                      body: controller.error!,
                      actionLabel: 'Qaytadan',
                      onAction: controller.load,
                    )
                  : items.isEmpty
                  ? const EmptyState(
                      icon: Icons.notifications_none,
                      title: 'Bildirishnomalar yoʻq',
                      body: 'Qidiruvni saqlab qoʻysangiz, mos eʼlon '
                          'chiqqanda birinchi boʻlib xabar beramiz.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          14, OtSize.x12, 14, OtSize.x24),
                      itemCount: items.length,
                      itemBuilder: (_, i) => NotificationTile(
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
          Expanded(child: Text('Bildirishnomalar', style: OtText.display)),
          if (c.unreadCount > 0)
            GestureDetector(
              onTap: c.markAllRead,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Text('Oʻqildi', style: OtText.link),
              ),
            ),
        ],
      ),
    );
  }
}
