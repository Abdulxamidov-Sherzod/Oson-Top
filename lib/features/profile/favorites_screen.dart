import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/paged_list.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/listing_grid.dart';
import '../../shared/widgets/load_more.dart';
import '../../state/favorites_controller.dart';
import '../listing_detail/listing_detail_screen.dart';
import '../../core/lang.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _scroll = ScrollController();
  late final PagedList<Listing> _paged = PagedList(fetch: _fetch);

  @override
  void initState() {
    super.initState();
    _paged.addListener(_onChange);
    attachLoadMore(_scroll, _paged.loadMore);
    _paged.load();
  }

  @override
  void dispose() {
    _paged
      ..removeListener(_onChange)
      ..dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  Future<PageResult<Listing>> _fetch({
    required int limit,
    required int offset,
  }) async {
    final page = await context
        .read<FavoritesRepository>()
        .list(limit: limit, offset: offset);
    if (mounted) {
      context.read<FavoritesController>().syncFrom({
        for (final item in page.items) item.id: true,
      });
    }
    return PageResult(items: page.items, total: page.total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OtColors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: _paged.state.when(
                loading: () => const ListingGridSkeleton(),
                error: (message) => EmptyState(
                  icon: Icons.cloud_off,
                  title: tr('Yuklab boʻlmadi'),
                  body: message,
                  actionLabel: 'Qaytadan',
                  onAction: _paged.load,
                ),
                data: (items) => items.isEmpty
                    ? EmptyState(
                        icon: Icons.favorite_border,
                        title: tr('Saqlangan eʼlonlar yoʻq'),
                        body: tr('Eʼlon yoqqan boʻlsa, yurakcha belgisini bosing — shu yerda saqlanadi.'),
                        actionLabel: tr('Eʼlonlarni koʻrish'),
                        onAction: () => Navigator.of(context).pop(),
                      )
                    : CustomScrollView(
                        controller: _scroll,
                        slivers: [
                          const SliverToBoxAdapter(
                              child: SizedBox(height: OtSize.x16)),
                          ListingGrid(
                            listings: items,
                            onTap: (l) => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ListingDetailScreen(listingId: l.id),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: LoadMoreFooter(paged: _paged),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          OtSize.screenPad, 10, OtSize.screenPad, 12),
      decoration: const BoxDecoration(
        color: OtColors.surface,
        border: Border(bottom: BorderSide(color: OtColors.lineFaint)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 36,
              height: OtSize.minTap,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.arrow_back_ios_new,
                    size: 20, color: OtColors.ink),
              ),
            ),
          ),
          Expanded(child: Text(tr('Saqlangan eʼlonlar'), style: OtText.display)),
        ],
      ),
    );
  }
}
