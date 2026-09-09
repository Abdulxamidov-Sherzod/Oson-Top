import 'package:flutter/material.dart';
import 'ot_colors.dart';

/// Ilova temasi. Ranglar va matn uslublari `OtColors` va `OtText` da —
/// bu yerda faqat Flutter'ning o'z komponentlari uchun sozlamalar.
final ThemeData otTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: OtColors.ground,
  colorScheme: ColorScheme.fromSeed(
    seedColor: OtColors.accent,
    primary: OtColors.accent,
    surface: OtColors.surface,
    error: OtColors.danger,
  ),
  splashFactory: InkSparkle.splashFactory,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: OtColors.accent,
    selectionHandleColor: OtColors.accent,
  ),
  // Tizim shrifti: iOS'da SF Pro, Android'da Roboto
  fontFamily: null,
);
