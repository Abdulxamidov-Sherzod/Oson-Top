import 'package:flutter_test/flutter_test.dart';
import 'package:oson_top/app.dart';

void main() {
  testWidgets('Ilova ochiladi va 3 ta tab koʻrinadi', (tester) async {
    await tester.pumpWidget(const OsonTopApp());

    expect(find.text('Bosh sahifa'), findsWidgets);
    expect(find.text('Eʼlon berish'), findsWidgets);
    expect(find.text('Profil'), findsWidgets);
  });
}
