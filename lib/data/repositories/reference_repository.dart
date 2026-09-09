import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/category.dart';

/// Kategoriyalar va tumanlar. Serverdan bir marta olinadi va saqlanadi —
/// ular kam o'zgaradi.
class ReferenceRepository {
  ReferenceRepository(this._api);

  final ApiClient _api;

  List<Category>? _categories;
  List<String>? _districts;

  /// Server ro'yxati faqat id va nom beradi — ikonalar ilovada
  static const _icons = <String, IconData>{
    'phones': Icons.smartphone_outlined,
    'cars': Icons.directions_car_outlined,
    'realty': Icons.home_outlined,
    'electro': Icons.desktop_windows_outlined,
    'furniture': Icons.weekend_outlined,
    'household': Icons.kitchen_outlined,
    'clothes': Icons.checkroom_outlined,
    'jobs': Icons.work_outline,
    'services': Icons.handyman_outlined,
    'animals': Icons.pets_outlined,
  };

  Future<List<Category>> categories() async {
    if (_categories != null) return _categories!;
    try {
      final resp = await _api.dio.get<dynamic>('/reference/categories');
      if (resp.statusCode != 200) throw ApiException.from(resp);
      _categories = (resp.data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((c) => Category(
                id: c['id'] as String,
                label: c['label'] as String,
                icon: _icons[c['id']] ?? Icons.category_outlined,
              ))
          .toList();
      return _categories!;
    } on DioException catch (e) {
      throw ApiException.network(e);
    }
  }

  Future<List<String>> districts() async {
    if (_districts != null) return _districts!;
    try {
      final resp = await _api.dio.get<dynamic>('/reference/districts');
      if (resp.statusCode != 200) throw ApiException.from(resp);
      _districts = (resp.data as List<dynamic>).cast<String>();
      return _districts!;
    } on DioException catch (e) {
      throw ApiException.network(e);
    }
  }

  /// Ekranlar sinxron ishlatadi — ilova ochilganda oldindan yuklanadi
  List<Category> get cachedCategories => _categories ?? const [];
  List<String> get cachedDistricts => _districts ?? const [];

  String labelOf(String categoryId) {
    for (final c in cachedCategories) {
      if (c.id == categoryId) return c.label;
    }
    return '';
  }
}
