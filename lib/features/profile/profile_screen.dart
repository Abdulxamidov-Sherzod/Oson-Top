import 'package:flutter/material.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../dev/component_gallery_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(OtSize.screenPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text('Profil', style: OtText.display),
            const SizedBox(height: OtSize.x12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: OtColors.fieldSoft,
                borderRadius: BorderRadius.circular(OtSize.rMd),
                border: Border.all(color: OtColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.construction_outlined,
                      size: 18, color: OtColors.inkFaint),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('7-qism da quriladi',
                        style: OtText.body.copyWith(color: OtColors.inkMuted)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: OtSize.x16),
            _devTile(context),
          ],
        ),
      ),
    );
  }

  /// 0-qism natijasini ko'rish uchun. Poydevor tugagach olib tashlanadi.
  Widget _devTile(BuildContext context) {
    return Material(
      color: OtColors.surface,
      borderRadius: BorderRadius.circular(OtSize.rMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(OtSize.rMd),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ComponentGalleryScreen()),
        ),
        child: Ink(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(OtSize.rMd),
            border: Border.all(color: OtColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: OtColors.accentSoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.widgets_outlined,
                    size: 18, color: OtColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Komponentlar', style: OtText.bodyStrong),
              ),
              const Icon(Icons.chevron_right,
                  size: 20, color: OtColors.dividerDot),
            ],
          ),
        ),
      ),
    );
  }
}
