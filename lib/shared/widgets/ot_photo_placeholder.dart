import 'package:flutter/material.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_text.dart';

/// Rasm o'rnidagi chiziqli fon. Haqiqiy rasmlar backend bilan keladi —
/// shu paytgacha hamma joyda shu ishlatiladi.
class OtPhotoPlaceholder extends StatelessWidget {
  const OtPhotoPlaceholder({
    super.key,
    this.label,
    this.large = false,
    this.labelAlignment = Alignment.bottomCenter,
  });

  /// Ustidagi yozuv, masalan "telefon rasmi"
  final String? label;

  /// Katta variant — e'lon sahifasidagi galereya uchun (ochroq chiziqlar)
  final bool large;

  final Alignment labelAlignment;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StripePainter(
        a: large ? OtColors.galleryStripeA : OtColors.photoStripeA,
        b: large ? OtColors.galleryStripeB : OtColors.photoStripeB,
        band: large ? 9 : 7,
      ),
      child: label == null
          ? const SizedBox.expand()
          : Align(
              alignment: labelAlignment,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  label!,
                  textAlign: TextAlign.center,
                  style: large ? OtText.monoMd : OtText.mono,
                ),
              ),
            ),
    );
  }
}

class _StripePainter extends CustomPainter {
  const _StripePainter({required this.a, required this.b, required this.band});

  final Color a;
  final Color b;
  final double band;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = b);

    final paint = Paint()
      ..color = a
      ..strokeWidth = band
      ..style = PaintingStyle.stroke;

    // 135° burchakdagi chiziqlar
    final step = band * 2 * 1.4142;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (var x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StripePainter old) =>
      old.a != a || old.b != b || old.band != band;
}
