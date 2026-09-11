import 'package:flutter/material.dart';

import '../../../core/theme/ot_colors.dart';
import '../../../shared/widgets/ot_photo_placeholder.dart';
import '../../../shared/widgets/ot_photo_viewer.dart';

/// Rasm galereyasi: surish, nuqtalar, hisoblagich.
/// Haqiqiy rasmlar backend bilan keladi — hozircha placeholder.
class PhotoGallery extends StatefulWidget {
  const PhotoGallery({
    super.key,
    required this.urls,
    required this.label,
    this.height = 330,
  });

  /// Bo'sh bo'lsa placeholder chiziladi
  final List<String> urls;
  final String label;
  final double height;

  int get _count => urls.isEmpty ? 1 : urls.length;

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  final _pager = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pager,
            itemCount: widget._count,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => widget.urls.isEmpty
                ? OtPhotoPlaceholder(
                    large: true,
                    label: widget.label,
                    labelAlignment: Alignment.center,
                  )
                : GestureDetector(
                    // Bosilganda to'liq ekranda ochiladi
                    onTap: () => OtPhotoViewer.open(
                      context,
                      urls: widget.urls,
                      initialIndex: i,
                    ),
                    child: Image.network(
                      widget.urls[i],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : const ColoredBox(
                                  color: OtColors.galleryStripeA),
                      errorBuilder: (_, _, _) => OtPhotoPlaceholder(
                        large: true,
                        label: widget.label,
                        labelAlignment: Alignment.center,
                      ),
                    ),
                  ),
          ),
          if (widget._count > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget._count; i++) _dot(i == _index),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _dot(bool active) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: active ? 18 : 5,
        height: 5,
        decoration: BoxDecoration(
          color: active
              ? OtColors.accent
              : OtColors.ink.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(3),
        ),
      );
}
