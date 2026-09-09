import 'package:flutter/material.dart';

/// Ilovaning barcha ranglari. Kodda `Color(0xFF...)` yozilmaydi — faqat shu yerdan.
/// Qiymatlar `design/oson-top-dizayn.html` dan olingan.
abstract final class OtColors {
  // Asosiy
  static const accent = Color(0xFF16A45C);
  static const accentPressed = Color(0xFF0E8C4C);
  static const accentSoft = Color(0xFFEFF7F2);
  static const accentSofter = Color(0xFFF1FAF5);
  static const accentTint = Color(0xFFDCEFE5);
  static const accentLine = Color(0xFFD8EEE3);
  static const accentInk = Color(0xFF2C6B4E);

  // Matn
  static const ink = Color(0xFF14201A);
  static const inkBody = Color(0xFF3F4B45);
  static const inkMuted = Color(0xFF6B7A72);
  static const inkFaint = Color(0xFF8D9A93);
  static const inkInactive = Color(0xFF9AA6A0);

  // Yuzalar
  static const surface = Color(0xFFFFFFFF);
  static const ground = Color(0xFFF4F6F5);
  static const field = Color(0xFFF6F8F7);
  static const fieldAlt = Color(0xFFF2F5F3);
  static const fieldSoft = Color(0xFFF8FAF9);

  // Chiziqlar
  static const line = Color(0xFFEDF0EE);
  static const lineFaint = Color(0xFFF1F3F2);
  static const lineStrong = Color(0xFFE3E8E5);
  static const lineField = Color(0xFFDCE3DF);
  static const dividerDot = Color(0xFFC7D0CB);

  // Holat
  static const danger = Color(0xFFE5484D);

  // Ogohlantirish bloki (e'lon sahifasidagi sariq)
  static const warnBg = Color(0xFFFFF8E8);
  static const warnLine = Color(0xFFF3E2B8);
  static const warnInk = Color(0xFF8A6116);
  static const warnInkStrong = Color(0xFF7A5410);
  static const warnIcon = Color(0xFFB7791F);

  // Rasm o'rnidagi chiziqli fon
  static const photoStripeA = Color(0xFFEEF2F0);
  static const photoStripeB = Color(0xFFF7F9F8);
  static const galleryStripeA = Color(0xFFEBF0ED);
  static const galleryStripeB = Color(0xFFF5F8F6);

  // Xarita (5-qismda ishlatiladi)
  static const mapLand = Color(0xFFE7EEE9);
  static const mapBlock = Color(0xFFD7E2DB);
  static const mapPark = Color(0xFFBEDCCB);
  static const mapWater = Color(0xFFBFD5E7);

  // Soyalar
  static const cardShadow = Color(0x12102214);
  static const liftShadow = Color(0x1F102214);
}
