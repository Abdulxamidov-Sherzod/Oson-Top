import 'package:flutter/material.dart';
import '../../core/theme/ot_colors.dart';
import '../create_listing/create_listing_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/ot_tab_bar.dart';

/// Ilovaning asosiy qobig'i: 3 ta tab va ular orasida almashish.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtColors.ground,
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          CreateListingScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: OtTabBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}
