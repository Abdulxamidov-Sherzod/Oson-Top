import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ot_colors.dart';
import '../../data/push/push_service.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../state/auth_controller.dart';
import '../../state/favorites_controller.dart';
import '../../state/notifications_controller.dart';
import '../auth/login_screen.dart';
import '../create_listing/create_listing_screen.dart';
import '../home/home_screen.dart';
import '../listing_detail/listing_detail_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/ot_tab_bar.dart';

/// Ilovaning asosiy qobig'i: 3 ta tab va ular orasida almashish.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialTab;
  bool _loadedForUser = false;

  void _go(int i) => setState(() => _index = i);

  /// E'lon berish uchun kirish kerak — lentani esa kirmasdan ko'rish mumkin
  Future<void> _onTab(int i) async {
    final auth = context.read<AuthController>();
    if (i == 1 && !auth.isSignedIn) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (!mounted || !context.read<AuthController>().isSignedIn) return;
    }
    _go(i);
  }

  /// Kirgandan keyin saqlanganlar va bildirishnomalarni bir marta yuklaymiz
  void _syncOnSignIn(AuthController auth) {
    if (auth.isSignedIn && !_loadedForUser) {
      _loadedForUser = true;
      context.read<FavoritesController>().load();
      context.read<NotificationsController>().refreshBadge();
      _startPush();
    } else if (!auth.isSignedIn) {
      _loadedForUser = false;
    }
  }

  void _startPush() {
    final repo = context.read<NotificationsRepository>();
    final notifications = context.read<NotificationsController>();

    PushService.register(repo);

    // Ilova ochiq turganda push ekranda ko'rinmaydi — hech bo'lmasa
    // qo'ng'iroqchadagi son yangilanadi
    PushService.onMessage(notifications.refreshBadge);

    PushService.onOpened((listingId) {
      if (!mounted) return;
      notifications.refreshBadge();
      if (listingId == null) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ListingDetailScreen(listingId: listingId),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOnSignIn(auth));

    return Scaffold(
      backgroundColor: OtColors.ground,
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          if (auth.isSignedIn)
            CreateListingScreen(onClose: () => _go(0))
          else
            const SizedBox.shrink(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: OtTabBar(index: _index, onChanged: _onTab),
    );
  }
}
