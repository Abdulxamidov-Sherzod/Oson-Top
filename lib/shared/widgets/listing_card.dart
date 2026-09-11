import 'package:flutter/material.dart';
import '../../core/format.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/models/listing.dart';
import 'ot_photo_placeholder.dart';
import 'ot_shimmer.dart';
import '../../core/lang.dart';

/// Lentadagi e'lon kartasi. Bosh sahifa, qidiruv, saqlanganlar va
/// e'lon berishning 2-qadamida ishlatiladi.
class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  /// Sarlavha uchun ajratilgan balandlik (2 qator × 13px × 1.3)
  static const double titleHeight = 34;

  /// Grid tilesi uchun tavsiya etilgan balandlik. Aniq bo'lishi shart emas —
  /// rasm qismi qolgan joyni o'zi to'ldiradi, shuning uchun matn shrifti
  /// platformadan platformaga farq qilsa ham karta buzilmaydi.
  static const double totalHeight = 248;

  /// Karta ichidagi bo'shliq
  static const double pad = 8;

  /// Karta va uning shimmer shakli bir xil koʻrinishi uchun
  static BoxDecoration get decoration => BoxDecoration(
        color: OtColors.surface,
        borderRadius: BorderRadius.circular(OtSize.rCard),
        border: Border.all(color: OtColors.line),
        boxShadow: const [
          BoxShadow(color: OtColors.cardShadow, blurRadius: 10, offset: Offset(0, 2)),
        ],
      );

  final Listing listing;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(pad),
        decoration: decoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rasm qolgan bo'sh joyni oladi — matn qancha joy so'rasa shuncha oladi
            Expanded(child: _photo()),
            const SizedBox(height: 7),
            // Ikki qatorlik joy doim band — lentada narxlar bir chiziqda turadi
            SizedBox(
              height: titleHeight,
              child: Text(
                listing.title,
                style: OtText.cardTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Text(tr(OtFormat.listingPrice(listing)), style: OtText.cardPrice),
            const SizedBox(height: 6),
            _meta(),
          ],
        ),
      ),
    );
  }

  Widget _photo() {
    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      decoration: BoxDecoration(
        color: OtColors.field,
        // Karta radiusidan kichikroq — ichma-ich burchaklar shunda to'g'ri turadi
        borderRadius: BorderRadius.circular(OtSize.rSm),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (listing.thumbUrl != null)
            Image.network(
              listing.thumbUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const ColoredBox(color: OtColors.field),
              errorBuilder: (_, _, _) =>
                  OtPhotoPlaceholder(label: listing.photoLabel),
            )
          else
            OtPhotoPlaceholder(label: listing.photoLabel),
          if (onFavoriteTap != null)
            Positioned(top: 8, right: 8, child: _favButton()),
        ],
      ),
    );
  }

  Widget _favButton() {
    return GestureDetector(
      onTap: onFavoriteTap,
      behavior: HitTestBehavior.opaque,
      // Bosish maydoni 44px — ko'rinadigan tugma 28px
      child: SizedBox(
        width: OtSize.minTap,
        height: OtSize.minTap,
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: OtColors.surface.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: OtColors.liftShadow, blurRadius: 3, offset: Offset(0, 1)),
              ],
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 15,
              color: isFavorite ? OtColors.accent : OtColors.inkMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta() {
    return Row(
      children: [
        Flexible(
          child: Text(
            tr(listing.district),
            style: OtText.meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: 3,
          height: 3,
          decoration: const BoxDecoration(
            color: OtColors.dividerDot,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(tr(OtFormat.timeAgo(listing.postedAt)), style: OtText.meta),
      ],
    );
  }
}


/// E'lon kartasining yuklanayotgandagi shakli. Tuzilishi `ListingCard` bilan
/// bir xil — shunda ma'lumot kelganda joylashuv sakramaydi.
class ListingCardSkeleton extends StatelessWidget {
  const ListingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ListingCard.pad),
      decoration: ListingCard.decoration,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: OtSkeleton.fill(radius: OtSize.rSm)),
          SizedBox(height: 7),
          SizedBox(
            height: ListingCard.titleHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OtSkeleton(height: 11),
                SizedBox(height: 6),
                OtSkeleton(width: 92, height: 11),
              ],
            ),
          ),
          SizedBox(height: 6),
          OtSkeleton(width: 104, height: 15),
          SizedBox(height: 8),
          OtSkeleton(width: 124, height: 9),
        ],
      ),
    );
  }
}
