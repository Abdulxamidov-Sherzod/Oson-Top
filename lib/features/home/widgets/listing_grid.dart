import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/ot_sizes.dart';
import '../../../data/models/listing.dart';
import '../../../shared/widgets/listing_card.dart';
import '../../../state/favorites_controller.dart';

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

  static const double _gap = 14;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesController>();
    final width = MediaQuery.sizeOf(context).width;
    final colWidth = (width - padding.horizontal - _gap) / 2;

    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: _gap,
          mainAxisSpacing: 18,
          childAspectRatio: colWidth / ListingCard.totalHeight,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final l = listings[i];
            return ListingCard(
              listing: l,
              isFavorite: favorites.isFavorite(l.id),
              onFavoriteTap: () => favorites.toggle(l.id),
              onTap: onTap == null ? null : () => onTap!(l),
            );
          },
          childCount: listings.length,
        ),
      ),
    );
  }
}
