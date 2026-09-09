import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';
import '../../../core/theme/ot_text.dart';
import '../../../data/models/seller.dart';

/// E'lon egasi haqidagi karta.
///
/// Reyting va sharh YO'Q — bizda hali sharh tizimi yo'q, soxta ishonch
/// belgisini ko'rsatmaymiz. O'rniga birinchi kundan bor bo'lgan ikki
/// ma'lumot: raqam tasdiqlangani va qachondan beri saytda ekani.
class SellerCard extends StatelessWidget {
  const SellerCard({super.key, required this.seller, this.onTap});

  final Seller seller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: OtColors.fieldSoft,
          borderRadius: BorderRadius.circular(OtSize.rLg),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: OtColors.accentTint,
                shape: BoxShape.circle,
              ),
              child: Text(
                seller.initials,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: OtColors.accentPressed,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller.name,
                    style: OtText.bodyStrong.copyWith(fontSize: 14.5),
                  ),
                  if (seller.phoneVerified) ...[
                    const SizedBox(height: 3),
                    const Row(
                      children: [
                        Icon(Icons.verified_outlined,
                            size: 14, color: OtColors.accent),
                        SizedBox(width: 5),
                        Text(
                          'Raqam tasdiqlangan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: OtColors.accentPressed,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 3),
                  Text(
                    '${OtFormat.memberSince(seller.memberSince)} · '
                    '${seller.listingCount} ta eʼlon',
                    style: OtText.metaSm,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right,
                  size: 20, color: OtColors.dividerDot),
          ],
        ),
      ),
    );
  }
}
