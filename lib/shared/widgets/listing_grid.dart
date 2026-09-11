import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ot_sizes.dart';
import '../../data/models/listing.dart';
import 'listing_card.dart';
import 'ot_shimmer.dart';
import '../../state/favorites_controller.dart';
import '../favorite_action.dart';

/// 2 ustunli e'lonlar lentasi. Saqlanganlar va qidiruv natijalari ham
/// shu widgetdan foydalanadi.
class ListingGrid extends StatelessWidget {
  const ListingGrid({
    super.key,
    required this.listings,
    this.onTap,
    this.padding = const EdgeInsets.fromLTRB(
        OtSize.screenPad, 0, OtSize.screenPad, OtSize.x24),
  });

  final List<Listing> listings;
  final void Function(Listing)? onTap;
  final EdgeInsets padding;

  static const double gap = 14;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesController>();
    final width = MediaQuery.sizeOf(context).width;
    final colWidth = (width - padding.horizontal - gap) / 2;

    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: gap,
          mainAxisSpacing: 18,
          childAspectRatio: colWidth / ListingCard.totalHeight,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final l = listings[i];
            return ListingCard(
              listing: l,
              isFavorite: favorites.isFavorite(l.id),
              onFavoriteTap: () => FavoriteAction.toggle(context, l.id),
              onTap: onTap == null ? null : () => onTap!(l),
            );
          },
          childCount: listings.length,
        ),
      ),
    );
  }
}


/// Lentaning yuklanayotgandagi ko'rinishi — `ListingGrid` bilan bir xil
/// panjara, ichida kartalarning shakli. Bo'sh ekrandagi aylanma
/// ko'rsatkichdan farqi: joylashuv oldindan ko'rinadi va ma'lumot kelganda
/// ekran sakramaydi.
class ListingGridSkeleton extends StatelessWidget {
  const ListingGridSkeleton({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(
        OtSize.screenPad, OtSize.x12, OtSize.screenPad, OtSize.x24),
  });

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final colWidth = (width - padding.horizontal - ListingGrid.gap) / 2;

    return OtShimmer(
      child: GridView.builder(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: ListingGrid.gap,
          mainAxisSpacing: 18,
          childAspectRatio: colWidth / ListingCard.totalHeight,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => const ListingCardSkeleton(),
      ),
    );
  }
}
