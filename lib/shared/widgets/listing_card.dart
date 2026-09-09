import 'package:flutter/material.dart';
import '../../core/format.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/models/listing.dart';
import 'ot_photo_placeholder.dart';

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
  static const double totalHeight = 232;

  final Listing listing;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
          const SizedBox(height: 7),
          Text(OtFormat.listingPrice(listing), style: OtText.cardPrice),
          const SizedBox(height: 7),
          _meta(),
        ],
      ),
    );
  }

  Widget _photo() {
    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      decoration: BoxDecoration(
        color: OtColors.field,
        borderRadius: BorderRadius.circular(OtSize.rCard),
        boxShadow: const [
          BoxShadow(color: OtColors.cardShadow, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
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
            listing.district,
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
        Text(OtFormat.timeAgo(listing.postedAt), style: OtText.meta),
      ],
    );
  }
}
