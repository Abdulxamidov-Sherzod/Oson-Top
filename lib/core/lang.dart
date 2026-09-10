import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lang_ru.dart';

/// Interfeys tili.
///
/// Kirillcha lotinchadan mexanik o'giriladi — alohida tarjima saqlanmaydi.
/// Ruscha esa haqiqiy tarjima talab qiladi, shuning uchun u lug'atdan olinadi.
enum OtLang {
  lotin('Oʻzbekcha', 'lotin'),
  kirill('Ўзбекча', 'kirill'),
  rus('Русский', 'rus');

  const OtLang(this.label, this.code);

  /// Tanlash ro'yxatida ko'rinadigan nom — o'z alifbosida yoziladi
  final String label;
  final String code;

  static OtLang byCode(String? code) =>
      OtLang.values.firstWhere((l) => l.code == code, orElse: () => OtLang.lotin);
}

/// Hozirgi til. `tr()` shu qiymatga qaraydi.
///
/// Global o'zgaruvchi — chunki `tr()` matn yozilgan har bir joyda chaqiriladi
/// va u yerlarda `BuildContext` bo'lavermaydi.
OtLang _current = OtLang.lotin;

OtLang get otLang => _current;

/// Matnni hozirgi tilga o'giradi.
///
/// Lotinchada matn o'zgarmaydi. Kirillchada harfma-harf o'giriladi —
/// shuning uchun `'$son ta eʼlon'` kabi qo'shib yasalgan matnlar ham
/// to'g'ri chiqadi.
String tr(String source) => switch (_current) {
      OtLang.lotin => source,
      OtLang.kirill => toCyrillic(source),
      OtLang.rus => toRussian(source),
    };

class LangController extends ChangeNotifier {
  LangController();

  OtLang get lang => _current;

  /// Ilova ochilganda saqlangan tilni tiklaydi
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _current = OtLang.byCode(prefs.getString(_key));
    notifyListeners();
  }

  Future<void> set(OtLang value) async {
    if (value == _current) return;
    _current = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.code);
  }

  static const _key = 'ot_lang';
}

// ---------------------------------------------------------------------------
// Lotin → kirill
// ---------------------------------------------------------------------------

/// Ikki harfli birikmalar birinchi tekshiriladi — aks holda `sh` "сҳ" bo'lib
/// ketadi. Ro'yxat tartibi shuning uchun muhim.
const _digraphs = <String, String>{
  'oʻ': 'ў', 'oʼ': 'ў', "o'": 'ў', 'o‘': 'ў',
  'gʻ': 'ғ', 'gʼ': 'ғ', "g'": 'ғ', 'g‘': 'ғ',
  'sh': 'ш', 'ch': 'ч',
  'ya': 'я', 'yo': 'ё', 'yu': 'ю',
};

const _singles = <String, String>{
  'a': 'а', 'b': 'б', 'd': 'д', 'e': 'е', 'f': 'ф', 'g': 'г', 'h': 'ҳ',
  'i': 'и', 'j': 'ж', 'k': 'к', 'l': 'л', 'm': 'м', 'n': 'н', 'o': 'о',
  'p': 'п', 'q': 'қ', 'r': 'р', 's': 'с', 't': 'т', 'u': 'у', 'v': 'в',
  'x': 'х', 'y': 'й', 'z': 'з', 'c': 'к',
  // Tutuq belgisi
  'ʼ': 'ъ', '’': 'ъ', '‘': 'ъ',
};

const _apostrophes = {'ʻ', 'ʼ', "'", '‘', '’'};

/// So'z boshidagi `e` — `э` ("eʼlon" → "эълон"), o'rtasida `е`.
bool _wordStart(String text, int i) {
  if (i == 0) return true;
  final prev = text[i - 1];
  return !RegExp(r'[a-zA-Zʻʼ‘’]').hasMatch(prev);
}

String toCyrillic(String source) {
  final out = StringBuffer();
  var i = 0;

  while (i < source.length) {
    final rest = source.substring(i);

    // Ikki harfli birikma
    var matched = false;
    for (final entry in _digraphs.entries) {
      final key = entry.key;
      if (rest.length < key.length) continue;
      final head = rest.substring(0, key.length);
      if (head.toLowerCase() != key) continue;

      // "yoʻq" — bu "yo" emas, "y" + "oʻ". Birikma o yoki g bilan tugab,
      // ketidan apostrof kelsa, apostrofli birikma ustun turadi.
      final tail = rest.length > key.length ? rest[key.length] : '';
      if (_apostrophes.contains(tail) &&
          RegExp('[og]').hasMatch(head[head.length - 1].toLowerCase())) {
        continue;
      }

      out.write(_keepCase(head, entry.value));
      i += key.length;
      matched = true;
      break;
    }
    if (matched) continue;

    final ch = source[i];
    final lower = ch.toLowerCase();

    if (lower == 'e') {
      out.write(_keepCase(ch, _wordStart(source, i) ? 'э' : 'е'));
    } else if (_singles.containsKey(lower)) {
      out.write(_keepCase(ch, _singles[lower]!));
    } else {
      // Raqam, tinish belgisi, bo'shliq — tegilmaydi
      out.write(ch);
    }
    i++;
  }

  return out.toString();
}

/// Lotincha bosh harf bo'lsa, kirillchasi ham bosh harf bo'ladi
String _keepCase(String source, String target) {
  final first = source[0];
  if (first == first.toLowerCase()) return target;
  if (source.length > 1 && source == source.toUpperCase()) {
    return target.toUpperCase();
  }
  return target[0].toUpperCase() + target.substring(1);
}


// ---------------------------------------------------------------------------
// Ruscha
// ---------------------------------------------------------------------------

/// Lug'at → qo'shma matnni bo'laklash → naqsh. Hech biri topmasa, matn
/// lotincha qoladi: bo'sh joy qolgandan ko'ra tushunarli.
String toRussian(String source) {
  final exact = ruDictionary[source];
  if (exact != null) return exact;

  // "Fargʻona shahri · 2026-yildan beri" — bo'laklari alohida o'giriladi
  if (source.contains(' · ')) {
    return source.split(' · ').map(toRussian).join(' · ');
  }

  for (final rule in _ruRules) {
    final match = rule.$1.firstMatch(source);
    if (match != null) return rule.$2(match);
  }
  return source;
}

/// Rus tilida son bilan kelishuv: 1 объявление · 2 объявления · 5 объявлений
String _plural(int n, String one, String few, String many) {
  final tens = n % 100;
  if (tens >= 11 && tens <= 14) return many;
  return switch (n % 10) {
    1 => one,
    2 || 3 || 4 => few,
    _ => many,
  };
}

int _n(RegExpMatch m, [int group = 1]) => int.parse(m.group(group)!);

final _ruRules = <(RegExp, String Function(RegExpMatch))>[
  (RegExp(r'^(\d+) daqiqa oldin$'),
      (m) => '${m[1]} ${_plural(_n(m), 'минуту', 'минуты', 'минут')} назад'),
  (RegExp(r'^(\d+) soat oldin$'),
      (m) => '${m[1]} ${_plural(_n(m), 'час', 'часа', 'часов')} назад'),
  (RegExp(r'^(\d+) kun oldin$'),
      (m) => '${m[1]} ${_plural(_n(m), 'день', 'дня', 'дней')} назад'),

  // "10-sentabr, 11:18" va "8-sentabr"
  (RegExp(r'^(\d+)-([a-z]+), (\d{2}:\d{2})$'),
      (m) => '${m[1]} ${ruMonths[m[2]] ?? m[2]!}, ${m[3]}'),
  (RegExp(r'^(\d+)-([a-z]+)$'), (m) => '${m[1]} ${ruMonths[m[2]] ?? m[2]!}'),

  (RegExp(r'^([\d\s]+) soʻm$'), (m) => '${m[1]} сум'),
  (RegExp(r'^([\d\s]+) soʻm / (.+)$'),
      (m) => '${m[1]} сум / ${toRussian(m[2]!)}'),

  (RegExp(r'^(\d+)-yildan beri$'), (m) => 'с ${m[1]} года'),

  (RegExp(r'^(\d+) ta eʼlon$'),
      (m) => '${m[1]} ${_plural(_n(m), 'объявление', 'объявления', 'объявлений')}'),
  (RegExp(r'^(\d+) natija$'),
      (m) => '${m[1]} ${_plural(_n(m), 'результат', 'результата', 'результатов')}'),
  (RegExp(r'^(\d+) koʻrish$'),
      (m) => '${m[1]} ${_plural(_n(m), 'просмотр', 'просмотра', 'просмотров')}'),

  (RegExp(r'^1-(\d+) dona$'), (m) => '1–${m[1]} шт.'),
];
