import 'package:flutter/material.dart';

import '../../core/theme/ot_colors.dart';

/// Yuklanayotgan mazmun o'rnida turadigan "shakl" va uning ustidan
/// sirg'aladigan yorug'lik.
///
/// Bo'sh ekrandagi aylanma ko'rsatkichdan farqi: foydalanuvchi nima
/// kelayotganini oldindan ko'radi va kutish qisqaroq tuyuladi.
class OtShimmer extends StatefulWidget {
  const OtShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<OtShimmer> createState() => _OtShimmerState();
}

class _OtShimmerState extends State<OtShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slide,
      // Bola qayta qurilmaydi — faqat ustidagi niqob suriladi
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            OtColors.fieldAlt,
            OtColors.surface,
            OtColors.fieldAlt,
          ],
          stops: const [0.35, 0.5, 0.65],
          // -1 dan 1 gacha: yorugʻlik chapdan oʻngga oʻtadi
          transform: _Slide(_slide.value * 2 - 1),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _Slide extends GradientTransform {
  const _Slide(this.progress);

  final double progress;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * progress, 0, 0);
}

/// Shimmer ichidagi bitta shakl — matn qatori, rasm yoki tugma o'rni.
class OtSkeleton extends StatelessWidget {
  const OtSkeleton({
    super.key,
    this.width,
    this.height = 12,
    this.radius = 7,
  });

  /// Berilmasa — butun enni egallaydi
  final double? width;
  final double height;
  final double radius;

  /// Rasm o'rni — qolgan bo'sh joyni oladi
  const OtSkeleton.fill({super.key, this.radius = 14})
      : width = null,
        height = double.infinity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: OtColors.fieldAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
