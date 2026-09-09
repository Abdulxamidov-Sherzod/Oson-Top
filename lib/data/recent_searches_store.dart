import 'package:shared_preferences/shared_preferences.dart';

/// So'nggi qidiruvlar telefon xotirasida saqlanadi — ilova yopilib
/// ochilganda ham qoladi.
class RecentSearchesStore {
  static const _key = 'recent_searches';
  static const _limit = 6;

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  Future<List<String>> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return load();

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];

    // Bir xil so'rov ikki marta turmasin — eng yangisi tepada
    list.removeWhere((e) => e.toLowerCase() == q.toLowerCase());
    list.insert(0, q);
    if (list.length > _limit) list.removeRange(_limit, list.length);

    await prefs.setStringList(_key, list);
    return list;
  }

  Future<List<String>> remove(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];
    list.remove(query);
    await prefs.setStringList(_key, list);
    return list;
  }

  Future<List<String>> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    return const [];
  }
}
