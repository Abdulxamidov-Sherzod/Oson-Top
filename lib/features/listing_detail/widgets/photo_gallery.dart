import 'package:flutter/material.dart';

import '../../../core/theme/ot_colors.dart';
import '../../../shared/widgets/ot_photo_placeholder.dart';

/// Rasm galereyasi: surish, nuqtalar, hisoblagich.
/// Haqiqiy rasmlar backend bilan keladi — hozircha placeholder.
class PhotoGallery extends StatefulWidget {
  const PhotoGallery({
    super.key,
    required this.count,
    required this.label,
    this.height = 330,
  });

  final int count;
  final String label;
  final double height;

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
            itemCount: widget.count,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => OtPhotoPlaceholder(
              large: true,
              label: '${i + 1} / ${widget.count} · ${widget.label}',
              labelAlignment: Alignment.center,
            ),
          ),
          if (widget.count > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.count; i++) _dot(i == _index),
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
