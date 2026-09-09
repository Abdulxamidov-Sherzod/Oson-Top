import 'package:flutter/material.dart';
import 'ot_colors.dart';

/// Matn uslublari. Kodda `TextStyle(...)` inline yozilmaydi — faqat shu yerdan.
/// Tizim shrifti ishlatiladi (iOS'da SF Pro, Android'da Roboto).
abstract final class OtText {
  static const _mono = <String>['Menlo', 'Roboto Mono', 'monospace'];

  /// Ekran sarlavhasi — "Bildirishnomalar", "Profil"
  static const display = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.48,
    color: OtColors.ink, height: 1.15,
  );

  /// Katta sarlavha — e'lon sahifasidagi narx
  static const priceLarge = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.52,
    color: OtColors.ink, height: 1.15,
  );

  /// Logotip va o'rta sarlavhalar
  static const title = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.4,
    color: OtColors.ink,
  );

  static const titleSm = TextStyle(
    fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.42,
    color: OtColors.ink,
  );

  /// Bo'lim sarlavhasi — "Tavsif", "O'xshash e'lonlar"
  static const section = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w700, color: OtColors.ink,
  );

  /// E'lon sarlavhasi batafsil sahifada
  static const listingTitle = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w600, height: 1.3, color: OtColors.ink,
  );

  /// Asosiy matn
  static const body = TextStyle(
    fontSize: 14, height: 1.55, color: OtColors.inkBody,
  );

  static const bodyStrong = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600, color: OtColors.ink,
  );

  /// Maydon yorlig'i — "Sarlavha", "Narx (so'm)"
  static const label = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600, color: OtColors.ink,
  );

  /// Kartadagi e'lon nomi (2 qatorgacha)
  static const cardTitle = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600, height: 1.3, color: OtColors.ink,
  );

  /// Kartadagi narx
  static const cardPrice = TextStyle(
    fontSize: 14.5, fontWeight: FontWeight.w700, letterSpacing: -0.145,
    color: OtColors.ink,
  );

  /// Kartadagi joy va vaqt
  static const meta = TextStyle(fontSize: 11, color: OtColors.inkFaint);

  /// E'lon sahifasidagi joy, sana, ko'rishlar
  static const metaMd = TextStyle(fontSize: 12.5, color: OtColors.inkMuted);

  static const metaSm = TextStyle(fontSize: 11.5, color: OtColors.inkFaint);

  /// Tab yorlig'i
  static const tab = TextStyle(fontSize: 10, fontWeight: FontWeight.w500);

  /// Tugma matni
  static const button = TextStyle(
    fontSize: 15.5, fontWeight: FontWeight.w700, color: OtColors.surface,
  );

  static const buttonGhost = TextStyle(
    fontSize: 15.5, fontWeight: FontWeight.w600, color: OtColors.ink,
  );

  /// Yashil havola matni — "O'zgartirish", "Barchasi"
  static const link = TextStyle(
    fontSize: 12.5, fontWeight: FontWeight.w600, color: OtColors.accent,
  );

  /// Rasm o'rnidagi yozuv
  static const mono = TextStyle(
    fontSize: 9, color: OtColors.inkFaint, letterSpacing: 0.18,
    fontFamilyFallback: _mono,
  );

  static const monoMd = TextStyle(
    fontSize: 10, color: OtColors.inkFaint, letterSpacing: 0.2,
    fontFamilyFallback: _mono,
  );
}
