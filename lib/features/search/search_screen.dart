import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/repositories/reference_repository.dart';
import '../../data/repositories/listing_repository.dart';
import '../../shared/widgets/district_sheet.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/listing_grid.dart';
import '../../shared/widgets/load_more.dart';
import '../../shared/widgets/ot_chip.dart';
import '../../shared/widgets/ot_segmented.dart';
import '../../state/favorites_controller.dart';
import '../listing_detail/listing_detail_screen.dart';
import 'search_controller.dart';
import 'widgets/filter_sheets.dart';
import 'widgets/search_suggestions.dart';
import '../../core/lang.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => SearchScreenController(
        ctx.read<ListingRepository>(),
        ctx.read<FavoritesController>(),
      )..setQuery(initialQuery),
      child: _SearchView(initialQuery: initialQuery),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView({required this.initialQuery});
  final String initialQuery;

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final _input = TextEditingController(text: widget.initialQuery);
  final _focus = FocusNode();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Ekran ochilishi bilan klaviatura chiqadi — odam darhol yoza boshlaydi
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    attachLoadMore(
      _scroll,
      () => context.read<SearchScreenController>().paged.loadMore(),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _pick(SearchScreenController c, String q) {
    _input.text = q;
    c.setQuery(q);
    c.saveQuery();
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<SearchScreenController>();

    return Scaffold(
      backgroundColor: OtColors.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _searchBar(c),
            _filterRow(c),
            Expanded(
              child: c.showSuggestions
                  ? SearchSuggestions(
                      recent: c.recent,
                      onPick: (q) => _pick(c, q),
                      onRemove: c.removeRecent,
                      onClearAll: c.clearRecent,
                    )
                  : _results(c),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(SearchScreenController c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, OtSize.screenPad, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: OtSize.minTap,
              height: OtSize.minTap,
              child: Icon(Icons.arrow_back_ios_new,
                  size: 20, color: OtColors.ink),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _focus.hasFocus ? OtColors.surface : OtColors.fieldAlt,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _focus.hasFocus
                      ? OtColors.accent
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: OtColors.inkFaint),
                  const SizedBox(width: 9),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      focusNode: _focus,
                      textInputAction: TextInputAction.search,
                      cursorColor: OtColors.accent,
                      style: const TextStyle(
                          fontSize: 15, color: OtColors.ink),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: tr('Nima qidiryapsiz?'),
                        hintStyle: TextStyle(
                            fontSize: 15, color: OtColors.inkFaint),
                      ),
                      onChanged: c.setQuery,
                      onSubmitted: (_) => c.saveQuery(),
                    ),
                  ),
                  if (c.query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _input.clear();
                        c.clearQuery();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.cancel,
                            size: 18, color: OtColors.inkFaint),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterRow(SearchScreenController c) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(OtSize.screenPad, 0, OtSize.screenPad, 8),
        children: [
          OtChip(
            label: c.categoryId == null
                ? 'Kategoriya'
                : context.read<ReferenceRepository>().labelOf(c.categoryId!),
            selected: c.categoryId != null,
            trailing: c.categoryId != null ? Icons.close : Icons.expand_more,
            onTap: () async {
              if (c.categoryId != null) return c.setCategory(null);
              final picked = await showCategoryFilter(context, c.categoryId);
              if (!mounted) return;
              c.setCategory(picked);
            },
          ),
          const SizedBox(width: 8),
          OtChip(
            label: c.district == allDistrictsLabel ? 'Tuman' : c.district,
            selected: c.district != allDistrictsLabel,
            trailing: c.district != allDistrictsLabel
                ? Icons.close
                : Icons.expand_more,
            onTap: () async {
              if (c.district != allDistrictsLabel) {
                return c.setDistrict(allDistrictsLabel);
              }
              final picked = await showDistrictSheet(
                context,
                c.district,
                context.read<ReferenceRepository>().cachedDistricts,
              );
              if (!mounted || picked == null) return;
              c.setDistrict(picked);
            },
          ),
          const SizedBox(width: 8),
          OtChip(
            label: _priceLabel(c),
            selected: !c.price.isEmpty,
            trailing: !c.price.isEmpty ? Icons.close : Icons.expand_more,
            onTap: () async {
              if (!c.price.isEmpty) return c.setPrice(const PriceRange());
              final picked = await showPriceFilter(context, c.price);
              if (!mounted || picked == null) return;
              c.setPrice(picked);
            },
          ),
          const SizedBox(width: 8),
          OtChip(
            label: tr(c.condition?.label ?? 'Holati'),
            selected: c.condition != null,
            trailing: c.condition != null ? Icons.close : Icons.expand_more,
            onTap: () async {
              if (c.condition != null) return c.setCondition(null);
              final picked = await showConditionFilter(context, c.condition);
              if (!mounted || picked == null) return;
              c.setCondition(picked.value);
            },
          ),
        ],
      ),
    );
  }

  String _priceLabel(SearchScreenController c) {
    final p = c.price;
    if (p.isEmpty) return 'Narx';
    if (p.min != null && p.max != null) {
      return '${_short(p.min!)}–${_short(p.max!)}';
    }
    if (p.min != null) return '${_short(p.min!)} dan';
    return '${_short(p.max!)} gacha';
  }

  /// 4 500 000 → "4.5 mln", 380 000 → "380 ming"
  String _short(int v) {
    if (v >= 1000000) {
      final m = v / 1000000;
      return '${m == m.roundToDouble() ? m.toInt() : m.toStringAsFixed(1)} mln';
    }
    if (v >= 1000) return '${v ~/ 1000} ming';
    return '$v';
  }

  Widget _results(SearchScreenController c) {
    return c.paged.state.when(
      loading: () => const ListingGridSkeleton(),
      error: (message) => EmptyState(
        icon: Icons.cloud_off,
        title: tr('Yuklab boʻlmadi'),
        body: message,
        actionLabel: 'Qaytadan',
        onAction: c.paged.load,
      ),
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: tr('Hech narsa topilmadi'),
            body: tr('Boshqa soʻz bilan qidirib koʻring yoki filtrlarni tozalang.'),
            actionLabel: c.hasFilters ? tr('Filtrlarni tozalash') : null,
            onAction: c.hasFilters ? c.resetFilters : null,
          );
        }

        return Container(
          color: OtColors.ground,
          child: CustomScrollView(
            controller: _scroll,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(OtSize.screenPad,
                      OtSize.x16, OtSize.screenPad, OtSize.x12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('${c.total} natija · ${c.district}'),
                        style: OtText.section,
                      ),
                      const SizedBox(height: OtSize.x12),
                      OtSegmented<SortOrder>(
                        options: {
                          for (final s in SortOrder.values) s: tr(s.label),
                        },
                        value: c.sort,
                        onChanged: c.setSort,
                      ),
                    ],
                  ),
                ),
              ),
              ListingGrid(
                listings: items,
                onTap: (l) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ListingDetailScreen(listingId: l.id),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: LoadMoreFooter(paged: c.paged)),
            ],
          ),
        );
      },
    );
  }
}
