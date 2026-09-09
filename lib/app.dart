import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/ot_theme.dart';
import 'data/repositories/listing_repository.dart';
import 'features/shell/app_shell.dart';
import 'state/favorites_controller.dart';
import 'state/notifications_controller.dart';

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
        home: const AppShell(),
      ),
    );
  }
}
