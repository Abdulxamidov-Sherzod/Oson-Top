import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/login_screen.dart';
import '../state/auth_controller.dart';
import '../state/favorites_controller.dart';
import '../core/lang.dart';

/// Yurakcha bosilganda nima bo'lishi.
///
/// Saqlash uchun kirish kerak. Kirmagan odamga xato ko'rsatish o'rniga
/// darhol kirish ekranini ochamiz — u kirgach yurakcha o'zi bosiladi.
abstract final class FavoriteAction {
  static Future<void> toggle(BuildContext context, String listingId) async {
    final auth = context.read<AuthController>();
    final favorites = context.read<FavoritesController>();

    if (!auth.isSignedIn) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (!context.mounted || !auth.isSignedIn) return;
      // Kirgandan keyin niyat bajariladi
      await _run(context, favorites, listingId);
      return;
    }

    await _run(context, favorites, listingId);
  }

  static Future<void> _run(
    BuildContext context,
    FavoritesController favorites,
    String listingId,
  ) async {
    try {
      await favorites.toggle(listingId);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('$error'))),
      );
    }
  }
}
