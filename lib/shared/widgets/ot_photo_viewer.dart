import 'package:flutter/material.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';

/// Rasmni to'liq ekranda ko'rish: barmoq bilan kattalashtirish, chapga-o'ngga
/// surish, pastga tortib yopish.
class OtPhotoViewer extends StatefulWidget {
  const OtPhotoViewer({
    super.key,
    required this.urls,
    this.initialIndex = 0,
  });

  final List<String> urls;
  final int initialIndex;

  /// Fon shaffof qolishi uchun alohida yo'l — shunda yopilayotganda
  /// ostidagi sahifa ko'rinib turadi
  static Future<void> open(
    BuildContext context, {
    required List<String> urls,
    int initialIndex = 0,
  }) {
    if (urls.isEmpty) return Future.value();
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: OtColors.viewerBackdrop,
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, _, _) =>
            OtPhotoViewer(urls: urls, initialIndex: initialIndex),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<OtPhotoViewer> createState() => _OtPhotoViewerState();
}

class _OtPhotoViewerState extends State<OtPhotoViewer> {
  late final PageController _pager =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  /// Kattalashtirishni kuzatamiz: rasm kattalashtirilgan bo'lsa, pastga
  /// tortish yopish emas, surish bo'lishi kerak
  final _zoom = TransformationController();

  double _dragY = 0;

  @override
  void dispose() {
    _pager.dispose();
    _zoom.dispose();
    super.dispose();
  }

  bool get _zoomed => _zoom.value.getMaxScaleOnAxis() > 1.01;

  void _onDragUpdate(DragUpdateDetails d) {
    if (_zoomed) return;
    setState(() => _dragY += d.delta.dy);
  }

  void _onDragEnd(DragEndDetails d) {
    if (_dragY.abs() > 110 || d.velocity.pixelsPerSecond.dy.abs() > 700) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _dragY = 0);
  }

  @override
  Widget build(BuildContext context) {
    // Pastga tortilgan sari fon shaffoflashadi
    final fade = (1 - (_dragY.abs() / 320)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: OtColors.viewerBackdrop.withValues(alpha: fade),
      body: GestureDetector(
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: Stack(
          children: [
            Transform.translate(
              offset: Offset(0, _dragY),
              child: PageView.builder(
                controller: _pager,
                itemCount: widget.urls.length,
                onPageChanged: (i) {
                  // Yangi rasm har doim asl o'lchamda ochiladi
                  _zoom.value = Matrix4.identity();
                  setState(() => _index = i);
                },
                itemBuilder: (_, i) => InteractiveViewer(
                  transformationController: i == _index ? _zoom : null,
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      widget.urls[i],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : const Center(
                                  child: SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: OtColors.surface,
                                    ),
                                  ),
                                ),
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.broken_image_outlined,
                        color: OtColors.inkInactive,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Opacity(
                opacity: fade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: OtSize.x12, vertical: OtSize.x4),
                  child: Row(
                    children: [
                      _round(Icons.close, () => Navigator.of(context).pop()),
                      const Spacer(),
                      if (widget.urls.length > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: OtColors.ink.withValues(alpha: 0.55),
                            borderRadius:
                                BorderRadius.circular(OtSize.rPill),
                          ),
                          child: Text(
                            '${_index + 1} / ${widget.urls.length}',
                            style: OtText.metaSm
                                .copyWith(color: OtColors.surface),
                          ),
                        ),
                      const Spacer(),
                      // O'ngdagi bo'sh joy — hisoblagich aynan markazda tursin
                      const SizedBox(width: OtSize.minTap),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: OtSize.minTap,
        height: OtSize.minTap,
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: OtColors.ink.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: OtColors.surface),
          ),
        ),
      ),
    );
  }
}
