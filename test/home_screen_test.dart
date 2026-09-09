import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oson_top/app.dart';
import 'package:oson_top/shared/widgets/listing_card.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    // iPhone 13 o'lchami — dizayn shu ekranga qarab qilingan
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const OsonTopApp());
    await tester.pumpAndSettle();
  }

  testWidgets('lenta 14 ta eʼlonni koʻrsatadi', (tester) async {
    await pumpApp(tester);
    expect(find.text('14 ta eʼlon'), findsOneWidget);
    expect(find.text('Yangi eʼlonlar'), findsOneWidget);
  });

  testWidgets('kategoriya bosilganda lenta filtrlanadi', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Telefonlar'));
    await tester.pumpAndSettle();

    // Telefonlar kategoriyasida 4 ta eʼlon bor
    expect(find.text('4 ta eʼlon'), findsOneWidget);
    expect(find.text('Telefonlar'), findsWidgets);

    // Qayta bosish filtrni bekor qiladi
    await tester.tap(find.text('Telefonlar').first);
    await tester.pumpAndSettle();
    expect(find.text('14 ta eʼlon'), findsOneWidget);
  });

  testWidgets('yurakcha bosilganda saqlangan holat oʻzgaradi', (tester) async {
    await pumpApp(tester);

    final firstCard = find.byType(ListingCard).first;
    expect(
      tester.widget<ListingCard>(firstCard).isFavorite,
      isFalse,
      reason: 'boshida hech narsa saqlanmagan',
    );

    await tester.tap(find.descendant(
      of: firstCard,
      matching: find.byIcon(Icons.favorite_border),
    ));
    await tester.pumpAndSettle();

    expect(
      tester.widget<ListingCard>(find.byType(ListingCard).first).isFavorite,
      isTrue,
    );
  });

  testWidgets('joylashuv tanlanganda lenta filtrlanadi', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Fargʻona viloyati'));
    await tester.pumpAndSettle();

    expect(find.text('Joylashuv'), findsOneWidget);

    await tester.tap(find.text('Qoʻqon').last);
    await tester.pumpAndSettle();

    // Qoʻqonda 1 ta eʼlon bor
    expect(find.text('1 ta eʼlon'), findsOneWidget);
    expect(find.text('Qoʻqon'), findsWidgets);
  });

  testWidgets('qidiruv qatori bosilganda qidiruv ekrani ochiladi',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Nima qidiryapsiz?'));
    await tester.pumpAndSettle();

    // Qidiruv ekrani ochildi: taklif qilingan soʻrovlar koʻrinadi
    expect(find.text('Koʻp qidiriladigan'), findsOneWidget);
    expect(find.text('Nexia 3'), findsOneWidget);
  });

  testWidgets('qoʻngʻiroqcha bildirishnomalar ekranini ochadi',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.pumpAndSettle();

    expect(find.text('Bildirishnomalar'), findsOneWidget);
  });
}
