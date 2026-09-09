import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oson_top/features/search/search_screen.dart';
import 'package:oson_top/data/repositories/listing_repository.dart';
import 'package:oson_top/state/favorites_controller.dart';
import 'package:oson_top/core/theme/ot_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpSearch(WidgetTester tester, {String query = ''}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider(create: (_) => ListingRepository()),
          ChangeNotifierProvider(create: (_) => FavoritesController()),
        ],
        child: MaterialApp(
          theme: otTheme,
          home: SearchScreen(initialQuery: query),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('boʻsh maydonda taklif qilingan soʻrovlar koʻrinadi',
      (tester) async {
    await pumpSearch(tester);
    expect(find.text('Koʻp qidiriladigan'), findsOneWidget);
    expect(find.text('Rishton keramika'), findsOneWidget);
  });

  testWidgets('soʻz yozilganda natijalar filtrlanadi', (tester) async {
    await pumpSearch(tester, query: 'iphone');
    // Mock maʼlumotda 3 ta iPhone bor
    expect(find.text('3 natija · Fargʻona viloyati'), findsOneWidget);
  });

  testWidgets('topilmasa boʻsh holat chiqadi', (tester) async {
    await pumpSearch(tester, query: 'traktor');
    expect(find.text('Hech narsa topilmadi'), findsOneWidget);
  });

  testWidgets('saralash narx boʻyicha tartiblaydi', (tester) async {
    await pumpSearch(tester, query: 'iphone');

    await tester.tap(find.text('Arzonidan'));
    await tester.pumpAndSettle();

    // Eng arzoni — iPhone 12, 3 400 000 soʻm
    expect(find.text('3 400 000 soʻm'), findsOneWidget);
  });

  testWidgets('kategoriya filtri natijani toraytiradi', (tester) async {
    await pumpSearch(tester, query: 'a');

    await tester.tap(find.text('Kategoriya'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hayvonlar').last);
    await tester.pumpAndSettle();

    expect(find.text('Hayvonlar'), findsWidgets);
    expect(find.text('1 natija · Fargʻona viloyati'), findsOneWidget);
  });
}
