import 'package:flutter/material.dart';

/// "Oson Top" yozuvli logo.
///
/// Rasm ikki qatorli (Oson / Top), nisbati ~1,68:1. Kenglik balandlikdan
/// kelib chiqadi — qatorga qo'yganda balandlikni berish qulayroq.
class OtLogo extends StatelessWidget {
  const OtLogo({super.key, this.height = 40});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      height: height,
      // Ekran o'qigichlar uchun — logo matn o'rnini bosadi
      semanticLabel: 'Oson Top',
    );
  }
}
