import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/ot_theme.dart';
import 'data/mock/mock_listings.dart';
import 'data/repositories/listing_repository.dart';
import 'features/listing_detail/listing_detail_screen.dart';
import 'features/create_listing/create_listing_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/search/search_screen.dart';
import 'features/shell/app_shell.dart';
import 'state/favorites_controller.dart';
import 'state/notifications_controller.dart';

/// Ishlab chiqish uchun: ilovani to'g'ridan-to'g'ri kerakli ekranda ochish.
///
///     flutter run --dart-define=start=search
///
/// Bo'sh bo'lsa odatdagidek bosh sahifadan boshlanadi.
const _startScreen = String.fromEnvironment('start');

Widget _home() => switch (_startScreen) {
      'search' => const SearchScreen(initialQuery: 'iphone'),
      'detail' => ListingDetailScreen(listing: mockListings.first),
      // E'lon sahifasining pastki qismini (joylashuv xaritasi) ko'rish uchun
      'detail_bottom' => ListingDetailScreen(
          listing: mockListings.first,
          debugScrollTo: 900,
        ),
      'create' => const CreateListingScreen(),
      'notifications' => const NotificationsScreen(),
      'profile' => const AppShell(initialTab: 2),
      _ => const AppShell(),
    };

class OsonTopApp extends StatelessWidget {
  const OsonTopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ListingRepository()),
        ChangeNotifierProvider(create: (_) => FavoritesController()),
        ChangeNotifierProvider(create: (_) => NotificationsController()),
      ],
      child: MaterialApp(
        title: 'Oson Top',
        debugShowCheckedModeBanner: false,
        theme: otTheme,
        home: _home(),
      ),
    );
  }
}
