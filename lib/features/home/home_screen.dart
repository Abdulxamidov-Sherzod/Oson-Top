import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/mock/mock_categories.dart';
import '../../data/repositories/listing_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../state/notifications_controller.dart';
import '../listing_detail/listing_detail_screen.dart';
import '../notifications/notifications_screen.dart';
import '../search/search_screen.dart';
import 'home_controller.dart';
import 'widgets/category_rail.dart';
import '../../shared/widgets/district_sheet.dart';
import 'widgets/home_header.dart';
import '../../shared/widgets/listing_grid.dart';
import 'widgets/search_bar_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => HomeController(ctx.read<ListingRepository>()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeController>();
    final unread = context.select<NotificationsController, int>(
      (n) => n.unreadCount,
    );
    final listings = home.listings;

    return Container(
      color: OtColors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Tepadagi qism scroll bilan ketmaydi — qidiruv doim ko'rinib turadi
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  OtSize.screenPad, 8, OtSize.screenPad, 0),
              child: Column(
                children: [
                  HomeHeader(
                    district: home.district,
                    unreadCount: unread,
                    onDistrictTap: () => _pickDistrict(context, home),
                    onBellTap: () => _open(context, const NotificationsScreen()),
                  ),
                  const SizedBox(height: OtSize.x12),
                  SearchBarButton(
                    onTap: () => _open(context, const SearchScreen()),
                  ),
                  const SizedBox(height: OtSize.x12),
                ],
              ),
            ),
            CategoryRail(
              selectedId: home.categoryId,
              onSelect: home.selectCategory,
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: OtColors.ground,
                  border: Border(top: BorderSide(color: OtColors.line)),
                ),
                child: listings.isEmpty
                    ? _empty(home)
                    : CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: _sectionHeader(home)),
                          ListingGrid(
                            listings: listings,
                            onTap: (l) => _open(
                              context,
                              ListingDetailScreen(listing: l),
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

  Widget _sectionHeader(HomeController home) {
    final title = home.categoryId == null
        ? 'Yangi eʼlonlar'
        : categoryLabel(home.categoryId!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          OtSize.screenPad, OtSize.x16, OtSize.screenPad, OtSize.x12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              title,
              style: OtText.section.copyWith(fontSize: 17),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text('${home.listings.length} ta eʼlon', style: OtText.metaSm),
        ],
      ),
    );
  }

  Widget _empty(HomeController home) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'Eʼlon topilmadi',
      body: home.district == 'Fargʻona viloyati'
          ? 'Bu kategoriyada hozircha eʼlon yoʻq. Boshqasini tanlab koʻring.'
          : '${home.district} boʻyicha bu kategoriyada eʼlon yoʻq.',
      actionLabel: 'Filtrni tozalash',
      onAction: () {
        home.selectDistrict('Fargʻona viloyati');
        if (home.categoryId != null) home.selectCategory(home.categoryId);
      },
    );
  }

  Future<void> _pickDistrict(BuildContext context, HomeController home) async {
    final picked = await showDistrictSheet(context, home.district);
    if (picked != null) home.selectDistrict(picked);
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}
