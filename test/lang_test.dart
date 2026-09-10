import 'package:flutter_test/flutter_test.dart';
import 'package:oson_top/core/lang.dart';

void main() {
  group('lotindan kirillga', () {
    test('tutuq belgisi va soʻz boshidagi e', () {
      expect(toCyrillic('eʼlon'), 'эълон');
      expect(toCyrillic('Eʼlon berish'), 'Эълон бериш');
      // Soʻz oʻrtasidagi e — е
      expect(toCyrillic('bepul'), 'бепул');
    });

    test('oʻ va gʻ', () {
      expect(toCyrillic('Fargʻona'), 'Фарғона');
      expect(toCyrillic('Koʻrishlar'), 'Кўришлар');
      expect(toCyrillic('soʻm'), 'сўм');
    });

    test('sh va ch', () {
      expect(toCyrillic('Bosh sahifa'), 'Бош саҳифа');
      expect(toCyrillic('Chiqish'), 'Чиқиш');
    });

    test('ya, yo, yu', () {
      expect(toCyrillic('Yangi'), 'Янги');
      expect(toCyrillic('yoʻq'), 'йўқ');
      expect(toCyrillic('yuborish'), 'юбориш');
    });

    test('raqam va tinish belgisi tegilmaydi', () {
      expect(toCyrillic('3 200 000 soʻm'), '3 200 000 сўм');
      expect(toCyrillic('+998901234567'), '+998901234567');
    });

    test('bosh harf saqlanadi', () {
      expect(toCyrillic('Saqlangan eʼlonlar'), 'Сақланган эълонлар');
      expect(toCyrillic('PROFIL'), 'ПРОФИЛ');
    });
  });

  test('lotinchada matn oʻzgarmaydi', () {
    expect(tr('Eʼlon berish'), 'Eʼlon berish');
  });

  ruTests();
}

void ruTests() {
  group('ruscha', () {
    test('lugʻatdan', () {
      expect(toRussian('Bosh sahifa'), 'Главная');
      expect(toRussian('Raqamni koʻrsatish'), 'Показать номер');
      expect(toRussian('Fargʻona shahri'), 'Фергана');
      expect(toRussian('Telefonlar'), 'Телефоны');
    });

    test('son bilan kelishuv', () {
      expect(toRussian('1 ta eʼlon'), '1 объявление');
      expect(toRussian('3 ta eʼlon'), '3 объявления');
      expect(toRussian('15 ta eʼlon'), '15 объявлений');
      expect(toRussian('21 ta eʼlon'), '21 объявление');
      expect(toRussian('2 soat oldin'), '2 часа назад');
      expect(toRussian('5 kun oldin'), '5 дней назад');
    });

    test('narx va sana', () {
      expect(toRussian('3 200 000 soʻm'), '3 200 000 сум');
      expect(toRussian('1 500 000 soʻm / oy'), '1 500 000 сум / мес.');
      expect(toRussian('10-sentabr, 11:18'), '10 сентября, 11:18');
      expect(toRussian('8-mart'), '8 марта');
    });

    test('qoʻshma matn boʻlaklab oʻgiriladi', () {
      expect(toRussian('Fargʻona shahri · 2026-yildan beri'),
          'Фергана · с 2026 года');
      expect(toRussian('2026-yildan beri · 3 ta eʼlon'),
          'с 2026 года · 3 объявления');
    });

    test('lugʻatda yoʻq matn lotincha qoladi', () {
      expect(toRussian('iPhone 13 Pro'), 'iPhone 13 Pro');
    });
  });
}
