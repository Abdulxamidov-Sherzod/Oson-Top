import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';

/// E'londagi joylashuv kartasi: xarita ko'rinishi, pin va manzil.
///
/// Hozircha chizma xarita — haqiqiy Yandex MapKit 5-qismda ulanadi.
/// Bosilganda Yandex Maps ilovasi (yoki brauzeri) ochiladi.
class StaticMapCard extends StatelessWidget {
  const StaticMapCard({
    super.key,
    required this.lat,
    required this.lng,
    required this.district,
    this.address,
    this.height = 150,
  });

  final double lat;
  final double lng;
  final String district;
  final String? address;
  final double height;

  Future<void> _openInMaps() async {
    // Yandex Maps: avval ilova, bo'lmasa brauzer
    final app = Uri.parse('yandexmaps://maps.yandex.ru/?pt=$lng,$lat&z=16');
    if (await canLaunchUrl(app)) {
      await launchUrl(app, mode: LaunchMode.externalApplication);
      return;
    }
    final web = Uri.parse('https://yandex.uz/maps/?pt=$lng,$lat&z=16&l=map');
    if (await canLaunchUrl(web)) {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openInMaps,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(OtSize.rCard),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: OtColors.lineStrong),
            borderRadius: BorderRadius.circular(OtSize.rCard),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _MapPainter(seed: lat + lng)),
              ),
              const Center(
                child: Padding(
                  // Pinning uchi markazda tursin
                  padding: EdgeInsets.only(bottom: 30),
                  child: _Pin(),
                ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: _chip('Yandex Maps', muted: true),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: _addressBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, {bool muted = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: OtColors.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: muted
              ? OtText.mono.copyWith(fontSize: 9.5)
              : OtText.link.copyWith(fontSize: 11.5),
        ),
      );

  Widget _addressBar() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: OtColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(11),
        boxShadow: const [
          BoxShadow(
            color: OtColors.liftShadow,
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.place_outlined, size: 15, color: OtColors.accent),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              address == null ? district : '$district, $address',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: OtColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Xaritada ochish', style: OtText.link),
        ],
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 30,
      height: 38,
      child: CustomPaint(painter: _PinPainter()),
    );
  }
}

class _PinPainter extends CustomPainter {
  const _PinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w / 2, h)
      ..cubicTo(w / 2 - w * 0.52, h * 0.55, 0, h * 0.42, 0, w / 2 * 0.78)
      ..arcToPoint(Offset(w, w / 2 * 0.78),
          radius: Radius.circular(w / 2), clockwise: true)
      ..cubicTo(w, h * 0.42, w / 2 + w * 0.52, h * 0.55, w / 2, h)
      ..close();

    canvas.drawPath(path, Paint()..color = OtColors.surface..strokeWidth = 4
      ..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round);
    canvas.drawPath(path, Paint()..color = OtColors.accent);
    canvas.drawCircle(
      Offset(w / 2, w / 2 * 0.85),
      w * 0.15,
      Paint()..color = OtColors.surface,
    );
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) => false;
}

/// Uslublangan xarita: kvartallar, park, suv va yo'llar.
/// Koordinataga qarab biroz siljiydi — har e'lon o'z ko'rinishiga ega bo'ladi.
class _MapPainter extends CustomPainter {
  const _MapPainter({required this.seed});

  final double seed;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Koordinatadan barqaror siljish — har safar bir xil chiziladi
    final dx = ((seed * 37) % 40) - 20;
    final dy = ((seed * 53) % 30) - 15;

    canvas.drawRect(Offset.zero & size, Paint()..color = OtColors.mapLand);

    final block = Paint()..color = OtColors.mapBlock;
    void rect(double x, double y, double bw, double bh) => canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + dx, y + dy, bw, bh),
            const Radius.circular(3),
          ),
          block,
        );

    rect(-20, -10, w * 0.36, h * 0.34);
    rect(w * 0.42, -10, w * 0.34, h * 0.34);
    rect(w * 0.82, -10, w * 0.4, h * 0.34);
    rect(-20, h * 0.46, w * 0.36, h * 0.4);
    rect(w * 0.42, h * 0.46, w * 0.34, h * 0.28);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.82 + dx, h * 0.46 + dy, w * 0.34, h * 0.3),
        const Radius.circular(8),
      ),
      Paint()..color = OtColors.mapPark,
    );

    final water = Path()
      ..moveTo(-10, h * 0.88 + dy)
      ..cubicTo(w * 0.25, h * 0.82 + dy, w * 0.45, h * 0.96 + dy,
          w * 0.7, h * 0.9 + dy)
      ..cubicTo(w * 0.85, h * 0.86 + dy, w * 0.95, h * 0.92 + dy,
          w + 10, h * 0.9 + dy)
      ..lineTo(w + 10, h + 10)
      ..lineTo(-10, h + 10)
      ..close();
    canvas.drawPath(water, Paint()..color = OtColors.mapWater);

    final road = Paint()
      ..color = OtColors.surface
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    road.strokeWidth = 12;
    canvas.drawLine(Offset(-10, h * 0.4 + dy), Offset(w + 10, h * 0.4 + dy), road);
    road.strokeWidth = 9;
    canvas.drawLine(Offset(w * 0.38 + dx, -10), Offset(w * 0.38 + dx, h + 10), road);
    road.strokeWidth = 5;
    canvas.drawLine(Offset(w * 0.78 + dx, -10), Offset(w * 0.78 + dx, h + 10), road);
    road.strokeWidth = 4;
    canvas.drawLine(Offset(-10, h * 0.13 + dy), Offset(w + 10, h * 0.13 + dy), road);
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.seed != seed;
}
