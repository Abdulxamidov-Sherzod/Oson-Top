import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/ot_colors.dart';

/// Bo'sh ekrandagi jonli tasvir.
///
/// Tayyor animatsiya fayli emas, kodda chiziladi: shunda ranglar aniq
/// `OtColors` dan bo'ladi, litsenziya masalasi chiqmaydi va fayl og'irligi
/// qo'shilmaydi. Har bir turi o'z ekranining ma'nosini takrorlaydi.
enum OtEmptyArt {
  /// Saqlanganlar — yurakcha o'zi chiziladi, to'ladi va urib qo'yadi
  heart,

  /// Mening e'lonlarim — bo'sh karta to'ladi va yuqoriga uchadi
  card,

  /// Bildirishnomalar — qo'ng'iroqcha tebranadi
  bell,

  /// Qidiruvda topilmadi — lupa bo'sh kartalar ustidan o'tadi
  search,
}

class OtEmptyArtView extends StatefulWidget {
  const OtEmptyArtView({super.key, required this.art, this.size = 132});

  final OtEmptyArt art;
  final double size;

  @override
  State<OtEmptyArtView> createState() => _OtEmptyArtViewState();
}

class _OtEmptyArtViewState extends State<OtEmptyArtView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(
          painter: switch (widget.art) {
            OtEmptyArt.heart => _HeartPainter(_c.value),
            OtEmptyArt.card => _CardPainter(_c.value),
            OtEmptyArt.bell => _BellPainter(_c.value),
            OtEmptyArt.search => _SearchPainter(_c.value),
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Yordamchilar
// ---------------------------------------------------------------------------

/// [from]..[to] oralig'ini 0..1 ga keltiradi, tashqarisi qirqiladi
double _phase(double t, double from, double to) =>
    ((t - from) / (to - from)).clamp(0.0, 1.0);

/// Yumshoq kirish-chiqish
double _ease(double t) => Curves.easeInOut.transform(t.clamp(0.0, 1.0));

/// Fon doirasi — hamma turda bir xil
void _backdrop(Canvas canvas, Size size, double grow) {
  final r = size.width * (0.44 + grow * 0.02);
  canvas.drawCircle(
    size.center(Offset.zero),
    r,
    Paint()..color = OtColors.accentSofter,
  );
  canvas.drawCircle(
    size.center(Offset.zero),
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = OtColors.accentLine,
  );
}

// ---------------------------------------------------------------------------
// Yurakcha
// ---------------------------------------------------------------------------

class _HeartPainter extends CustomPainter {
  _HeartPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    _backdrop(canvas, size, 0);

    final box = Rect.fromCenter(
      center: size.center(Offset.zero).translate(0, size.height * 0.015),
      width: size.width * 0.50,
      height: size.width * 0.45,
    );

    // Urishdan tarqaladigan halqa
    final pulse = _phase(t, 0.0, 0.55);
    if (pulse > 0 && pulse < 1) {
      canvas.drawCircle(
        box.center,
        size.width * (0.22 + 0.20 * pulse),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = OtColors.accent.withValues(alpha: (1 - pulse) * 0.35),
      );
    }

    // Yurakcha har doim to'liq turadi — faqat ozgina uradi
    final beat = math.sin(_phase(t, 0.0, 0.30) * math.pi) * 0.07;
    canvas.save();
    canvas.translate(box.center.dx, box.center.dy);
    canvas.scale(1 + beat);
    canvas.translate(-box.center.dx, -box.center.dy);

    final heart = _heartPath(box);
    canvas.drawPath(heart, Paint()..color = OtColors.accentTint);
    canvas.drawPath(
      heart,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = OtColors.accent,
    );
    canvas.restore();
  }

  Path _heartPath(Rect r) {
    final w = r.width, h = r.height;
    return Path()
      ..moveTo(r.left + w * 0.5, r.top + h * 0.95)
      ..cubicTo(r.left + w * 0.06, r.top + h * 0.60, r.left + w * 0.04,
          r.top + h * 0.18, r.left + w * 0.28, r.top + h * 0.10)
      ..cubicTo(r.left + w * 0.41, r.top + h * 0.06, r.left + w * 0.47,
          r.top + h * 0.18, r.left + w * 0.5, r.top + h * 0.28)
      ..cubicTo(r.left + w * 0.53, r.top + h * 0.18, r.left + w * 0.59,
          r.top + h * 0.06, r.left + w * 0.72, r.top + h * 0.10)
      ..cubicTo(r.left + w * 0.96, r.top + h * 0.18, r.left + w * 0.94,
          r.top + h * 0.60, r.left + w * 0.5, r.top + h * 0.95)
      ..close();
  }

  @override
  bool shouldRepaint(_HeartPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Karta
// ---------------------------------------------------------------------------

class _CardPainter extends CustomPainter {
  _CardPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    _backdrop(canvas, size, 0);

    // Sekin suzib turadi
    final float = math.sin(t * math.pi * 2) * size.height * 0.018;
    canvas.save();
    canvas.translate(0, float);

    final card = Rect.fromCenter(
      center: size.center(Offset.zero).translate(-size.width * 0.03, 0),
      width: size.width * 0.44,
      height: size.width * 0.52,
    );
    final rr = RRect.fromRectAndRadius(card, const Radius.circular(9));

    canvas.drawRRect(rr, Paint()..color = OtColors.surface);
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = OtColors.accentLine,
    );

    // Ichi har doim to'liq: rasm, sarlavha, narx
    final pad = card.width * 0.13;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(card.left + pad, card.top + pad,
            card.width - pad * 2, card.height * 0.40),
        const Radius.circular(5),
      ),
      Paint()..color = OtColors.accentTint,
    );

    void bar(double top, double widthFactor) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(card.left + pad, card.top + card.height * top,
              (card.width - pad * 2) * widthFactor, 4),
          const Radius.circular(2),
        ),
        Paint()..color = OtColors.lineField,
      );
    }

    bar(0.60, 0.9);
    bar(0.74, 0.55);

    // Burchakdagi "+" — yangi e'lon qo'shish. Urib turadi.
    final grow = math.sin(_phase(t, 0.1, 0.6) * math.pi);
    final badge = Offset(card.right, card.bottom - card.height * 0.10);
    final radius = size.width * 0.10 * (1 + grow * 0.12);
    canvas.drawCircle(badge, radius + 3,
        Paint()..color = OtColors.accentSofter);
    canvas.drawCircle(badge, radius, Paint()..color = OtColors.accent);
    final arm = radius * 0.45;
    final plus = Paint()
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = OtColors.surface;
    canvas.drawLine(badge.translate(-arm, 0), badge.translate(arm, 0), plus);
    canvas.drawLine(badge.translate(0, -arm), badge.translate(0, arm), plus);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CardPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Qo'ng'iroqcha
// ---------------------------------------------------------------------------

class _BellPainter extends CustomPainter {
  _BellPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    _backdrop(canvas, size, 0);

    // Ikki marta tebranadi, keyin tinchiydi
    final ring = _phase(t, 0.08, 0.42);
    final angle = math.sin(ring * math.pi * 4) * 0.18 * (1 - ring);

    final center = size.center(Offset.zero);
    canvas.save();
    canvas.translate(center.dx, center.dy - size.height * 0.16);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -(center.dy - size.height * 0.16));

    final w = size.width * 0.30;
    final h = size.width * 0.34;
    final top = center.dy - h * 0.55;

    final body = Path()
      ..moveTo(center.dx - w / 2, top + h)
      ..lineTo(center.dx + w / 2, top + h)
      ..cubicTo(center.dx + w * 0.34, top + h * 0.72, center.dx + w * 0.40,
          top + h * 0.10, center.dx, top)
      ..cubicTo(center.dx - w * 0.40, top + h * 0.10, center.dx - w * 0.34,
          top + h * 0.72, center.dx - w / 2, top + h)
      ..close();

    canvas.drawPath(body, Paint()..color = OtColors.accentTint);
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round
        ..color = OtColors.accent,
    );
    // Tili
    canvas.drawCircle(
      Offset(center.dx, top + h + 4),
      3.4,
      Paint()..color = OtColors.accent,
    );
    canvas.restore();

    // Yonidagi to'lqinlar — tebranish paytida
    final wave = math.sin(ring * math.pi);
    if (wave > 0.02) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = OtColors.accent.withValues(alpha: wave * 0.55);
      for (final side in [-1.0, 1.0]) {
        final x = center.dx + side * size.width * 0.26;
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(x, center.dy - size.height * 0.02),
              width: 16,
              height: 22),
          side < 0 ? math.pi * 0.6 : -math.pi * 0.4,
          math.pi * 0.8,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BellPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Qidiruv
// ---------------------------------------------------------------------------

class _SearchPainter extends CustomPainter {
  _SearchPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    _backdrop(canvas, size, 0);

    // Ortidagi bo'sh kartalar
    final faint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = OtColors.accentLine;
    for (var i = 0; i < 2; i++) {
      // Ikkalasi markazga nisbatan simmetrik tursin
      final r = Rect.fromLTWH(
        size.width * (0.30 + i * 0.24),
        size.height * 0.34,
        size.width * 0.18,
        size.width * 0.26,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(6)),
        faint,
      );
    }

    // Lupa chapdan o'ngga o'tadi va ozgina qiyshayadi
    final sweep = _ease(_phase(t, 0.1, 0.7));
    final x = size.width * (0.33 + 0.34 * sweep);
    final y = size.height * (0.52 + math.sin(sweep * math.pi) * -0.06);
    final radius = size.width * 0.13;

    final glass = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = OtColors.accent;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(math.sin(sweep * math.pi * 2) * 0.12);
    canvas.drawCircle(Offset.zero, radius,
        Paint()..color = OtColors.surface.withValues(alpha: 0.85));
    canvas.drawCircle(Offset.zero, radius, glass);
    canvas.drawLine(
      Offset(radius * 0.72, radius * 0.72),
      Offset(radius * 1.35, radius * 1.35),
      glass,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SearchPainter old) => old.t != t;
}
