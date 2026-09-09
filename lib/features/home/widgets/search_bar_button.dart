import 'package:flutter/material.dart';
import '../../../core/theme/ot_colors.dart';

/// Bosh sahifadagi qidiruv qatori. O'zi yozib bo'lmaydi — bosilganda
/// qidiruv ekrani ochiladi (2-qism).
class SearchBarButton extends StatelessWidget {
  const SearchBarButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: OtColors.fieldAlt,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, size: 18, color: OtColors.inkFaint),
            SizedBox(width: 9),
            Text(
              'Nima qidiryapsiz?',
              style: TextStyle(fontSize: 15, color: OtColors.inkFaint),
            ),
          ],
        ),
      ),
    );
  }
}
