import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/repositories/listing_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/listing_grid.dart';
import '../../state/favorites_controller.dart';
import '../listing_detail/listing_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesController>();
    final items = context.read<ListingRepository>().byIds(favorites.ids);

    return Scaffold(
      backgroundColor: OtColors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
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
                  Expanded(
                    child: Text('Saqlangan eʼlonlar', style: OtText.display),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
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
                                  ListingDetailScreen(listing: l),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
