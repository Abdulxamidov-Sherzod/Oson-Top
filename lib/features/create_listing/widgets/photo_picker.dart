import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../create_listing_form.dart';

import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';
import '../../../core/theme/ot_text.dart';
import '../../../core/lang.dart';

/// Rasm tanlash. Birinchi rasm asosiy bo'ladi — lentada shu ko'rinadi.
class PhotoPicker extends StatelessWidget {
  const PhotoPicker({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    required this.onRetry,
    required this.maxPhotos,
    this.error,
  });

  final List<PickedPhoto> photos;
  final ValueChanged<ImageSource> onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onRetry;
  final int maxPhotos;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: OtText.label,
            children: [
              TextSpan(text: tr('Rasmlar')),
              TextSpan(
                text: tr(' · 1-$maxPhotos dona'),
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  color: OtColors.inkFaint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length + (photos.length < maxPhotos ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) => i < photos.length
                ? _thumb(i)
                : _addSlot(context),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error!,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: OtColors.danger,
            ),
          ),
        ] else if (photos.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            tr('Birinchi rasm asosiy — lentada shu koʻrinadi.'),
            style: OtText.metaSm,
          ),
        ],
      ],
    );
  }

  Widget _addSlot(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickSource(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          color: OtColors.fieldSoft,
          borderRadius: BorderRadius.circular(OtSize.rCard),
          border: Border.all(
            color: const Color(0xFFBFD4C8),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 22, color: OtColors.accent),
            SizedBox(height: 5),
            Text(
              tr('Rasm qoʻshish'),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: OtColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb(int i) {
    final photo = photos[i];
    return SizedBox(
      width: 86,
      height: 86,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(OtSize.rCard),
            child: Image.file(
              File(photo.file.path),
              width: 86,
              height: 86,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: OtColors.field),
            ),
          ),
          // Yuklanmoqda — ustiga xira parda va aylana
          if (photo.uploading)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: OtColors.ink.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(OtSize.rCard),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: OtColors.surface,
                    ),
                  ),
                ),
              ),
            )
          // Yuklanmadi — bosib qayta urinish mumkin
          else if (photo.error != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => onRetry(i),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: OtColors.danger.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(OtSize.rCard),
                  ),
                  child: const Center(
                    child: Icon(Icons.refresh,
                        size: 22, color: OtColors.surface),
                  ),
                ),
              ),
            ),
          if (i == 0 && !photo.uploading && photo.error == null)
            Positioned(
              left: 4,
              bottom: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: OtColors.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tr('asosiy'),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: OtColors.surface,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => onRemove(i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.all(4),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: OtColors.ink.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.close,
                    size: 13, color: OtColors.surface),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickSource(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: OtColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(OtSize.rSheet)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: OtColors.lineField,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: OtColors.accent),
              title: Text(tr('Galereyadan tanlash')),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_camera_outlined, color: OtColors.accent),
              title: Text(tr('Suratga olish')),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source != null) onAdd(source);
  }
}
