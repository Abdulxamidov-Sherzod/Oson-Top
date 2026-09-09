import 'package:flutter/material.dart';
import '../models/category.dart';

/// Bosh sahifadagi kategoriya rail va e'lon berish formasidagi ro'yxat.
const mockCategories = <Category>[
  Category(id: 'phones',   label: 'Telefonlar',   icon: Icons.smartphone_outlined),
  Category(id: 'cars',     label: 'Avtomobil',    icon: Icons.directions_car_outlined),
  Category(id: 'realty',   label: 'Uy-joy',       icon: Icons.home_outlined),
  Category(id: 'electro',  label: 'Elektronika',  icon: Icons.desktop_windows_outlined),
  Category(id: 'furniture',label: 'Mebel',        icon: Icons.weekend_outlined),
  Category(id: 'household',label: 'Uy-roʻzgʻor',  icon: Icons.kitchen_outlined),
  Category(id: 'clothes',  label: 'Kiyim',        icon: Icons.checkroom_outlined),
  Category(id: 'jobs',     label: 'Ish oʻrni',    icon: Icons.work_outline),
  Category(id: 'services', label: 'Xizmatlar',    icon: Icons.handyman_outlined),
  Category(id: 'animals',  label: 'Hayvonlar',    icon: Icons.pets_outlined),
];

Category? categoryById(String id) {
  for (final c in mockCategories) {
    if (c.id == id) return c;
  }
  return null;
}

String categoryLabel(String id) => categoryById(id)?.label ?? '';
