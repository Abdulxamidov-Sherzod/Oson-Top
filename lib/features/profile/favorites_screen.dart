import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/async_value.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/listing_grid.dart';
import '../../state/favorites_controller.dart';
import '../listing_detail/listing_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Async<List<Listing>> _state = const Async.loading();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = const Async.loading());
    try {
      final page = await context.read<FavoritesRepository>().list();
      if (!mounted) return;
      setState(() => _state = Async.data(page.items));
      context.read<FavoritesController>().syncFrom({
        for (final item in page.items) item.id: true,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = Async.error('$e'));
    }
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
              child: _state.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: OtColors.accent),
                ),
                error: (message) => EmptyState(
                  icon: Icons.cloud_off,
                  title: 'Yuklab boʻlmadi',
                  body: message,
                  actionLabel: 'Qaytadan',
                  onAction: _load,
                ),
                data: (items) => items.isEmpty
                    ? EmptyState(
                        icon: Icons.favorite_border,
                        title: 'Saqlangan eʼlonlar yoʻq',
                        body: 'Eʼlon yoqqan boʻlsa, yurakcha belgisini '
                            'bosing — shu yerda saqlanadi.',
                        actionLabel: 'Eʼlonlarni koʻrish',
                        onAction: () => Navigator.of(context).pop(),
                      )
                    : CustomScrollView(
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
          Expanded(child: Text('Saqlangan eʼlonlar', style: OtText.display)),
        ],
      ),
    );
  }
}
