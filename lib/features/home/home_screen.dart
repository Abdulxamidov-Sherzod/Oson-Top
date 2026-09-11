import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/listing_repository.dart';
import '../../data/repositories/reference_repository.dart';
import '../../shared/widgets/district_sheet.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/listing_grid.dart';
import '../../shared/widgets/load_more.dart';
import '../../state/favorites_controller.dart';
import '../../state/notifications_controller.dart';
import '../listing_detail/listing_detail_screen.dart';
import '../notifications/notifications_screen.dart';
import '../search/search_screen.dart';
import 'home_controller.dart';
import 'widgets/category_rail.dart';
import 'widgets/home_header.dart';
import 'widgets/search_bar_button.dart';
import '../../core/lang.dart';
import '../../shared/widgets/ot_empty_art.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => HomeController(
        ctx.read<ListingRepository>(),
        ctx.read<FavoritesController>(),
      ),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    attachLoadMore(_scroll, () => context.read<HomeController>().paged.loadMore());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeController>();
    final unread = context.select<NotificationsController, int>(
      (n) => n.unreadCount,
    );

    return Container(
      color: OtColors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  OtSize.screenPad, 8, OtSize.screenPad, 0),
              child: Column(
                children: [
                  HomeHeader(
                    district: home.district,
                    unreadCount: unread,
                    onDistrictTap: () => _pickDistrict(home),
                    onBellTap: () => _open(const NotificationsScreen()),
                  ),
                  const SizedBox(height: OtSize.x12),
                  SearchBarButton(onTap: () => _open(const SearchScreen())),
                  const SizedBox(height: OtSize.x12),
                ],
              ),
            ),
            CategoryRail(
              categories: context.read<ReferenceRepository>().cachedCategories,
              selectedId: home.categoryId,
              onSelect: home.selectCategory,
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: OtColors.ground,
                  border: Border(top: BorderSide(color: OtColors.line)),
                ),
                child: home.paged.state.when(
                  loading: () => const ListingGridSkeleton(),
                  error: (message) => EmptyState(
                    icon: Icons.cloud_off,
                    title: tr('Yuklab boʻlmadi'),
                    body: message,
                    actionLabel: 'Qaytadan',
                    onAction: home.paged.load,
                  ),
                  data: (items) =>
                      items.isEmpty ? _empty(home) : _feed(home, items),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feed(HomeController home, List<Listing> items) {
    return RefreshIndicator(
      color: OtColors.accent,
      onRefresh: home.paged.refresh,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverToBoxAdapter(child: _sectionHeader(home)),
          ListingGrid(
            listings: items,
            onTap: (l) => _open(ListingDetailScreen(listingId: l.id)),
          ),
          SliverToBoxAdapter(child: LoadMoreFooter(paged: home.paged)),
        ],
      ),
    );
  }

  Widget _sectionHeader(HomeController home) {
    final reference = context.read<ReferenceRepository>();
    final title = home.categoryId == null
        ? tr('Yangi eʼlonlar')
        : tr(reference.labelOf(home.categoryId!));

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
          Text(tr('${home.total} ta eʼlon'), style: OtText.metaSm),
        ],
      ),
    );
  }

  Widget _empty(HomeController home) {
    return EmptyState(
      icon: Icons.search_off,
      art: OtEmptyArt.search,
      title: tr('Eʼlon topilmadi'),
      body: home.district == allDistricts
          ? tr('Bu kategoriyada hozircha eʼlon yoʻq. Boshqasini tanlab koʻring.')
          : '${home.district} boʻyicha bu kategoriyada eʼlon yoʻq.',
      actionLabel: tr('Filtrni tozalash'),
      onAction: home.resetFilters,
    );
  }

  Future<void> _pickDistrict(HomeController home) async {
    final districts = context.read<ReferenceRepository>().cachedDistricts;
    final picked = await showDistrictSheet(context, home.district, districts);
    if (picked != null) home.selectDistrict(picked);
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}
