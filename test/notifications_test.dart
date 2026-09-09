import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oson_top/core/theme/ot_theme.dart';
import 'package:oson_top/features/notifications/notifications_screen.dart';
import 'package:oson_top/state/notifications_controller.dart';
import 'package:provider/provider.dart';

void main() {
  Future<NotificationsController> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = NotificationsController();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: otTheme,
          home: const NotificationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('roʻyxat va oʻqilmaganlar soni koʻrinadi', (tester) async {
    final c = await pump(tester);
    expect(c.unreadCount, 2);
    expect(find.text('Eʼloningiz tasdiqlandi'), findsOneWidget);
    expect(find.text('Oʻqildi'), findsOneWidget);
  });

  testWidgets('«Oʻqildi» hammasini oʻqilgan qiladi', (tester) async {
    final c = await pump(tester);

    await tester.tap(find.text('Oʻqildi'));
    await tester.pumpAndSettle();

    expect(c.unreadCount, 0);
    // Tugma yoʻqoladi — oʻqilmagani qolmadi
    expect(find.text('Oʻqildi'), findsNothing);
  });

  testWidgets('bitta bildirishnoma bosilganda oʻqilgan boʻladi',
      (tester) async {
    final c = await pump(tester);

    await tester.tap(find.text('Siz qidirgan iPhone 13 eʼloni joylandi'));
    await tester.pumpAndSettle();

    expect(c.unreadCount, 1);
  });
}
