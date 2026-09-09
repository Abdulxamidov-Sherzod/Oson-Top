import 'package:flutter_test/flutter_test.dart';
import 'package:oson_top/core/format.dart';

void main() {
  group('narx', () {
    test('uch xonadan boʻshliq bilan ajratiladi', () {
      expect(OtFormat.number(3200000), '3 200 000');
      expect(OtFormat.number(950), '950');
      expect(OtFormat.number(132000000), '132 000 000');
    });

    test('nol — «Kelishiladi»', () {
      expect(OtFormat.price(0), 'Kelishiladi');
    });

    test('oylik narx birlik bilan chiqadi', () {
      expect(OtFormat.price(4500000, unit: 'oy'), '4 500 000 soʻm / oy');
    });
  });

  group('vaqt', () {
    final now = DateTime(2026, 9, 9, 14, 0);

    test('bir soat ichida daqiqada', () {
      expect(
        OtFormat.timeAgo(now.subtract(const Duration(minutes: 22)), now: now),
        '22 daqiqa oldin',
      );
    });

    test('bugun — soatda', () {
      expect(
        OtFormat.timeAgo(now.subtract(const Duration(hours: 5)), now: now),
        '5 soat oldin',
      );
    });

    test('kecha', () {
      expect(OtFormat.timeAgo(DateTime(2026, 9, 8, 20), now: now), 'Kecha');
    });

    test('bir haftadan oshsa — sana', () {
      expect(OtFormat.timeAgo(DateTime(2026, 8, 20), now: now), '20-avgust');
    });
  });

  test('toʻliq sana', () {
    expect(OtFormat.fullDate(DateTime(2026, 9, 8, 14, 20)), '8-sentabr, 14:20');
  });
}
