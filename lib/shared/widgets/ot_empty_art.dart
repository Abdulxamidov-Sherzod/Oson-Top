import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/ot_colors.dart';

/// Bo'sh ekrandagi jonli tasvir.
///
/// Tayyor animatsiya fayli emas, kodda chiziladi: shunda ranglar aniq
/// `OtColors` dan bo'ladi, litsenziya masalasi chiqmaydi va fayl og'irligi
/// qo'shilmaydi. Har bir turi o'z ekranining ma'nosini takrorlaydi.
enum OtEmptyArt {
  /// Saqlanganlar — toʻla yurakcha "lub-dub" qilib urib turadi
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

  /// Qalinlik necha qavatdan yigʻiladi. Qavat qancha koʻp boʻlsa, yon
  /// yuza shuncha silliq — 132px tasvirda yigirmatasi yetadi.
  static const _layers = 22;

  /// Oʻq sanchiladigan payt
  static const _hit = 0.46;

  /// Yurak urishi — "lub-dub": kuchli zarba, ortidan kuchsizrogʻi, keyin
  /// tinchlik. Bitta tekis pulsatsiya soatning chiqillashiga oʻxshab
  /// qolardi, ikkitasi esa darhol yurak deb oʻqiladi.
  static double _beat(double t) {
    double hit(double from, double to, double power) {
      final p = _phase(t, from, to);
      if (p <= 0 || p >= 1) return 0;
      return math.sin(p * math.pi) * power;
    }

    // Uchinchisi — oʻq tekkandagi silkinish
    return hit(0.00, 0.13, 0.18) +
        hit(0.15, 0.30, 0.10) +
        hit(_hit, _hit + 0.13, 0.14);
  }

  /// Zarbadan tarqaladigan halqa
  void _ring(Canvas canvas, Offset center, double radius, double p) {
    if (p <= 0 || p >= 1) return;
    canvas.drawCircle(
      center,
      radius * (0.55 + 0.75 * _ease(p)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * (1 - p)
        ..color = OtColors.accent.withValues(alpha: (1 - p) * 0.32),
    );
  }

  /// Oʻq — pastki chapdan uchib kelib yurakka sanchiladi va shu yerda
  /// qoladi. Yurakning old yuzasidan OLDIN chiziladi: shunda oʻqning
  /// oʻrtasi yurak ichida yoʻqoladi, ikki uchi esa tashqarida koʻrinadi.
  void _arrow(Canvas canvas, Rect box, double w) {
    final fly = _ease(_phase(t, 0.16, _hit));
    if (fly <= 0) return;

    // Oxirida yoʻqoladi — halqa yopilganda oʻq birdan gʻoyib boʻlmasin
    final fade = 1 - _phase(t, 0.90, 1.0);
    if (fade <= 0) return;

    const angle = -0.52; // pastki chapdan yuqori oʻngga
    final dir = Offset(math.cos(angle), math.sin(angle));
    final perp = Offset(-dir.dy, dir.dx);

    // Uchib kelayotganda oʻz oʻqi boʻylab suriladi
    final approach = (1 - fly) * w * 2.6;
    // Sanchilgandan keyin qaltiraydi va tez tinchiydi
    final since = t - _hit;
    final shake = since > 0
        ? math.sin(since * 78) * math.exp(-since * 22) * w * 0.05
        : 0.0;

    final shift = dir * -approach + perp * shake;
    // Yurak eni ~1 birlik: oʻq undan ikki barobar uzun boʻlsin, shunda
    // ikkala uchi ham tashqarida aniq koʻrinadi
    final tail = box.center + dir * (-w * 1.00) + shift;
    final tip = box.center + dir * (w * 0.92) + shift;

    final ink = Paint()
      ..color = OtColors.ink.withValues(alpha: fade)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.05;

    canvas.drawLine(tail, tip, ink);

    // Uchi
    final head = w * 0.17;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - dir.dx * head + perp.dx * head * 0.52,
            tip.dy - dir.dy * head + perp.dy * head * 0.52)
        ..lineTo(tip.dx - dir.dx * head - perp.dx * head * 0.52,
            tip.dy - dir.dy * head - perp.dy * head * 0.52)
        ..close(),
      Paint()..color = OtColors.ink.withValues(alpha: fade),
    );

    // Patlari — orqaga qarab yotadi
    for (var i = 0; i < 3; i++) {
      final base = tail + dir * (w * 0.11 * (i + 1));
      canvas.drawLine(
        base,
        base - dir * (w * 0.11) + perp * (w * 0.085),
        ink,
      );
      canvas.drawLine(
        base,
        base - dir * (w * 0.11) - perp * (w * 0.085),
        ink,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Uchib kelayotgan oʻq tasvir chegarasidan tashqarida boshlanadi —
    // qirqib qoʻyilmasa, pastdagi sarlavha ustiga chiqib ketadi
    canvas.clipRect(Offset.zero & size);
    _backdrop(canvas, size, 0);

    final center = size.center(Offset.zero).translate(0, size.height * 0.015);
    // Shakl markazda chiziladi — burilish, urish va oʻq shu nuqta atrofida
    final box = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.50,
      height: size.width * 0.45,
    );
    final heart = _heartPath(box);
    // Bitta qavat qalinligi. Hammasi qoʻshilib yurak enining chorak
    // qismicha chuqurlik beradi — koʻzga hajm boʻlib koʻrinadi, lekin
    // shakl choʻzilib ketmaydi.
    final depth = size.width * 0.0085;

    _ring(canvas, center, size.width * 0.30, _phase(t, 0.00, 0.45));
    _ring(canvas, center, size.width * 0.26, _phase(t, 0.15, 0.58));
    _ring(canvas, center, size.width * 0.34, _phase(t, _hit, _hit + 0.34));

    final beat = _beat(t);
    // Sekin u yoqdan-bu yoqqa buriladi. Toʻliq aylanmaydi: yonboshiga
    // kelganda yurak ingichka chiziqqa aylanib, tanib boʻlmay qolardi.
    final turn = math.sin(t * math.pi * 2) * 0.55;
    final tilt = math.sin(t * math.pi * 2 + 1.2) * 0.13;

    /// Kuzatuvchidan [z] chuqurlikdagi qatlam. Perspektiva tufayli
    /// orqadagi qavatlar kichrayadi — hajm shundan seziladi.
    Matrix4 scene(double z) => Matrix4.identity()
      ..setEntry(3, 2, 0.0016)
      ..rotateY(turn)
      ..rotateX(tilt)
      ..translateByDouble(0.0, 0.0, z, 1.0);

    // Urish yurakni kattalashtiradi, oʻqni emas — shuning uchun alohida
    Matrix4 layer(double z) =>
        scene(z)..scaleByDouble(1 + beat, 1 + beat * 0.82, 1.0, 1.0);

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Ostidagi soya — yurak fon ustida osilib turibdi
    canvas.save();
    canvas.transform((Matrix4.identity()
          ..setEntry(3, 2, 0.0016)
          ..translateByDouble(
              0.0, size.height * 0.055, -depth * _layers, 1.0))
        .storage);
    canvas.drawPath(
      heart,
      Paint()
        ..color = OtColors.accentInk.withValues(alpha: 0.16 + beat * 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.05),
    );
    canvas.restore();

    // Yon yuza: bir xil shakl orqaga qarab qatlanadi. Burilganda aynan
    // shu qatlamlar koʻrinib, yurak yassi emasligi bilinadi.
    for (var i = _layers; i >= 1; i--) {
      final k = i / _layers;
      canvas.save();
      canvas.transform(layer(-depth * i).storage);
      // Chizish ham, toʻldirish ham — qavatlar orasida ingichka oq
      // tirqish qolmasin
      final paint = Paint()
        ..color =
            Color.lerp(OtColors.accentPressed, OtColors.accentInk, k * 0.85)!
        ..style = PaintingStyle.fill;
      canvas.drawPath(heart, paint);
      canvas.drawPath(
        heart,
        Paint()
          ..color = paint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      canvas.restore();
    }

    // Oʻq yurak bilan birga buriladi, lekin urishda kattalashmaydi
    canvas.save();
    canvas.transform(scene(-depth * _layers * 0.5).storage);
    _arrow(canvas, box, box.width);
    canvas.restore();

    // Old yuza
    canvas.save();
    canvas.transform(layer(0).storage);
    canvas.drawPath(
      heart,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [OtColors.accent, OtColors.accentPressed],
        ).createShader(box),
    );

    // Yaltiroq dogʻ yurak bilan birga burilmaydi — yorugʻlik manbai
    // qoʻzgʻalmas, shuning uchun dogʻ burilishga teskari suriladi.
    canvas.save();
    canvas.clipPath(heart);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          box.width * (-0.20 - turn * 0.22),
          box.height * (-0.22 - tilt * 0.3),
        ),
        width: box.width * 0.34,
        height: box.height * 0.26,
      ),
      Paint()
        ..color = OtColors.surface.withValues(alpha: 0.42)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.028),
    );
    // Pastki chekka toʻqroq — shakl oʻz ustiga qayrilgandek koʻrinadi
    canvas.drawPath(
      heart.shift(Offset(0, -box.height * 0.16)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = box.height * 0.18
        ..color = OtColors.accentInk.withValues(alpha: 0.20)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.035),
    );
    canvas.restore();
    canvas.restore();

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
