import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/mock/mock_categories.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/listing_repository.dart';
import '../../shared/widgets/listing_card.dart';
import '../../shared/widgets/static_map_card.dart';
import '../../state/favorites_controller.dart';
import 'widgets/contact_bar.dart';
import 'widgets/photo_gallery.dart';
import 'widgets/safety_note.dart';
import 'widgets/seller_card.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({
    super.key,
    required this.listing,
    this.debugScrollTo,
  });

  final Listing listing;

  /// Faqat ishlab chiqish uchun: ekranni shu joygacha aylantirib ochadi
  /// (`--dart-define=start=detail_bottom`). Ilovada ishlatilmaydi.
  final double? debugScrollTo;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ListingRepository>();
    final seller = repo.sellerOf(listing);
    final similar = repo.similarTo(listing);

    return Scaffold(
      backgroundColor: OtColors.surface,
      body: Stack(
        children: [
          CustomScrollView(
            controller: debugScrollTo == null
                ? null
                : ScrollController(initialScrollOffset: debugScrollTo!),
            slivers: [
              _appBar(context),
              SliverToBoxAdapter(child: _head()),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: OtSize.screenPad),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SellerCard(seller: seller),
                      const SizedBox(height: OtSize.x12),
                      const SafetyNote(),
                      const SizedBox(height: OtSize.x24),
                      Text('Tavsif', style: OtText.section),
                      const SizedBox(height: OtSize.x8),
                      Text(listing.description, style: OtText.body),
                      if (listing.specs.isNotEmpty) ...[
                        const SizedBox(height: OtSize.x24),
                        Text('Maʼlumotlar', style: OtText.section),
                        const SizedBox(height: OtSize.x4),
                        _specs(),
                      ],
                      if (listing.hasLocation) ...[
                        const SizedBox(height: OtSize.x24),
                        Text('Joylashuv', style: OtText.section),
                        const SizedBox(height: OtSize.x12),
                        StaticMapCard(
                          lat: listing.lat!,
                          lng: listing.lng!,
                          district: listing.district,
                          address: listing.address,
                        ),
                        const SizedBox(height: OtSize.x8),
                        const Text(
                          'Xaritada taxminiy hudud koʻrsatilgan.',
                          style: OtText.metaSm,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (similar.isNotEmpty)
                SliverToBoxAdapter(child: _similar(context, similar)),
              const SliverToBoxAdapter(child: SizedBox(height: OtSize.x24)),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ContactBar(phone: seller.phone),
          ),
        ],
      ),
    );
  }

  /// Galereya app bar sifatida: scroll qilinganda yig'ilib, oq panelga aylanadi.
  Widget _appBar(BuildContext context) {
    final favorites = context.watch<FavoritesController>();
    final fav = favorites.isFavorite(listing.id);

    return SliverAppBar(
      pinned: true,
      expandedHeight: 330,
      backgroundColor: OtColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: const Border(bottom: BorderSide(color: OtColors.line)),
      leadingWidth: 58,
      leading: Center(
        child: _round(Icons.arrow_back_ios_new,
            onTap: () => Navigator.of(context).pop()),
      ),
      actions: [
        _round(
          fav ? Icons.favorite : Icons.favorite_border,
          color: fav ? OtColors.accent : OtColors.ink,
          onTap: () => favorites.toggle(listing.id),
        ),
        const SizedBox(width: 8),
        _round(Icons.ios_share, onTap: () {}),
        const SizedBox(width: 14),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: PhotoGallery(
          count: listing.photoCount,
          label: listing.photoLabel,
        ),
      ),
    );
  }

  Widget _head() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          OtSize.screenPad, 18, OtSize.screenPad, OtSize.x12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(OtFormat.listingPrice(listing), style: OtText.priceLarge),
          const SizedBox(height: OtSize.x8),
          Text(listing.title, style: OtText.listingTitle),
          const SizedBox(height: OtSize.x12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _tag(categoryLabel(listing.categoryId), accent: true),
              if (listing.condition != ListingCondition.none)
                _tag(listing.condition.label),
            ],
          ),
          const SizedBox(height: OtSize.x12),
          _metaRow(),
        ],
      ),
    );
  }

  Widget _tag(String label, {bool accent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent ? OtColors.accentSoft : OtColors.field,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: accent ? OtColors.accentLine : OtColors.lineStrong,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: accent ? OtColors.accentPressed : OtColors.inkMuted,
        ),
      ),
    );
  }

  Widget _metaRow() {
    final place = listing.address == null
        ? listing.district
        : '${listing.district}, ${listing.address}';
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _metaItem(Icons.place_outlined, place),
        _metaItem(Icons.schedule, OtFormat.fullDate(listing.postedAt)),
        _metaItem(Icons.visibility_outlined, '${listing.views} koʻrish'),
      ],
    );
  }

  Widget _metaItem(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: OtColors.inkFaint),
          const SizedBox(width: 5),
          Text(text, style: OtText.metaMd),
        ],
      );

  Widget _specs() {
    return Column(
      children: [
        for (var i = 0; i < listing.specs.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              border: i == listing.specs.length - 1
                  ? null
                  : const Border(
                      bottom: BorderSide(color: OtColors.lineFaint)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.specs[i].label, style: OtText.metaMd),
                const Spacer(),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    listing.specs[i].value,
                    textAlign: TextAlign.right,
                    style: OtText.bodyStrong.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _similar(BuildContext context, List<Listing> items) {
    final favorites = context.watch<FavoritesController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: OtSize.x24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: OtSize.screenPad),
          child: Text('Oʻxshash eʼlonlar', style: OtText.section),
        ),
        const SizedBox(height: OtSize.x12),
        SizedBox(
          height: ListingCard.totalHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: OtSize.screenPad),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) => SizedBox(
              width: 150,
              child: ListingCard(
                listing: items[i],
                isFavorite: favorites.isFavorite(items[i].id),
                onFavoriteTap: () => favorites.toggle(items[i].id),
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ListingDetailScreen(listing: items[i]),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Pastdagi bogʻlanish paneli ostida qolib ketmasin
        const SizedBox(height: 96),
      ],
    );
  }

  Widget _round(IconData icon,
      {required VoidCallback onTap, Color color = OtColors.ink}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: OtColors.surface.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: OtColors.liftShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}
