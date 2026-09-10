import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/theme/ot_colors.dart';
import 'core/theme/ot_sizes.dart';
import 'core/theme/ot_theme.dart';
import 'data/api/api_client.dart';
import 'data/api/token_store.dart';
import 'data/repositories/create_listing_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/listing_repository.dart';
import 'data/repositories/notifications_repository.dart';
import 'data/repositories/reference_repository.dart';
import 'features/auth/login_screen.dart';
import 'features/create_listing/create_listing_screen.dart';
import 'features/listing_detail/listing_detail_screen.dart';
import 'features/map_picker/map_picker_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/search/search_screen.dart';
import 'features/shell/app_shell.dart';
import 'shared/widgets/ot_logo.dart';
import 'state/auth_controller.dart';
import 'state/favorites_controller.dart';
import 'state/notifications_controller.dart';
import 'core/lang.dart';

/// Ilovaning barcha provayderlari. Alohida funksiya — testda butun
/// ilovani ko'tarmasdan tekshirib ko'rish mumkin.
List<SingleChildWidget> appProviders(ApiClient api, TokenStore tokens) => [
      Provider.value(value: api),
      Provider(create: (_) => ListingRepository(api)),
      Provider(create: (_) => ReferenceRepository(api)),
      Provider(create: (_) => FavoritesRepository(api)),
      Provider(create: (_) => CreateListingRepository(api)),
      Provider(create: (_) => NotificationsRepository(api)),
      ChangeNotifierProvider(create: (_) => LangController()..load()),
      ChangeNotifierProvider(create: (_) => AuthController(api, tokens)),
      ChangeNotifierProvider(
        create: (ctx) => FavoritesController(ctx.read<FavoritesRepository>()),
      ),
      ChangeNotifierProvider(
        create: (ctx) =>
            NotificationsController(ctx.read<NotificationsRepository>()),
      ),
    ];

class OsonTopApp extends StatelessWidget {
  const OsonTopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = TokenStore();
    final api = ApiClient(tokens);

    return MultiProvider(
      providers: appProviders(api, tokens),
      // `tr()` matn yozilgan joyda chaqiriladi va hech qanday provayderga
      // obuna boʻlmaydi, shuning uchun til almashganda oddiy qayta qurish
      // yetmaydi: yoʻldagi `const` widgetlar oʻzgarmagani uchun Flutter
      // ularning ostini butunlay chetlab oʻtadi. Kalit almashsa esa daraxt
      // yangidan quriladi.
      child: Consumer<LangController>(
        builder: (_, lang, _) => MaterialApp(
          key: ValueKey(lang.lang),
          title: 'Oson Top',
          debugShowCheckedModeBanner: false,
          theme: otTheme,
          home: const _Root(),
        ),
      ),
    );
  }
}

/// Ilova ochilganda ma'lumotnomani yuklab, keyin qobiqni ko'rsatadi.
class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  late final Future<void> _ready = _prepare();

  Future<void> _prepare() async {
    final reference = context.read<ReferenceRepository>();
    // Kategoriyalar va tumanlar ekranlarda sinxron kerak bo'ladi
    await Future.wait([reference.categories(), reference.districts()]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _Splash();
        }
        if (snapshot.hasError) {
          return _ConnectionError(onRetry: () => setState(() {}));
        }
        return _startScreen();
      },
    );
  }
}

/// Ishlab chiqish uchun: ilovani to'g'ridan-to'g'ri kerakli ekranda ochish.
///
///     flutter run --dart-define=start=detail --dart-define=listing=14
///
/// Bo'sh bo'lsa odatdagidek bosh sahifadan boshlanadi.
const _start = String.fromEnvironment('start');
const _listingId = String.fromEnvironment('listing', defaultValue: '14');
const _scroll = int.fromEnvironment('scroll');

Widget _startScreen() => switch (_start) {
      'search' => const SearchScreen(initialQuery: 'iphone'),
      'detail' => ListingDetailScreen(
          listingId: _listingId,
          debugScrollTo: _scroll == 0 ? null : _scroll.toDouble(),
        ),
      'create' => const CreateListingScreen(),
      'notifications' => const NotificationsScreen(),
      'login' => const LoginScreen(),
      'map' => const MapPickerScreen(),
      'profile' => const AppShell(initialTab: 2),
      _ => const AppShell(),
    };

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: OtColors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OtLogo(height: 100),
            SizedBox(height: OtSize.x24),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: OtColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionError extends StatelessWidget {
  const _ConnectionError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtColors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 40, color: OtColors.inkFaint),
              const SizedBox(height: 16),
              Text(
                tr('Serverga ulanib boʻlmadi'),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: OtColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tr('Internetni tekshiring va qaytadan urinib koʻring.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: OtColors.inkMuted,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(onPressed: onRetry, child: Text(tr('Qaytadan'))),
            ],
          ),
        ),
      ),
    );
  }
}
