import 'package:flutter/material.dart';
import '../../core/theme/ot_colors.dart';
import '../create_listing/create_listing_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/ot_tab_bar.dart';

/// Ilovaning asosiy qobig'i: 3 ta tab va ular orasida almashish.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialTab = 0});

  /// Qaysi tabdan boshlanadi (0 — bosh sahifa)
  final int initialTab;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialTab;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtColors.ground,
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          CreateListingScreen(onClose: () => _go(0)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: OtTabBar(
        index: _index,
        onChanged: _go,
      ),
    );
  }
}
