import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../core/paged_list.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/listing_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/load_more.dart';
import '../../shared/widgets/ot_photo_placeholder.dart';
import '../listing_detail/listing_detail_screen.dart';
import '../../core/lang.dart';

/// Mening e'lonlarim. Foydalanuvchi mock — hozircha `s1` sotuvchining
/// e'lonlari ko'rsatiladi. Backend qo'shilganda haqiqiy egasi bo'yicha filtrlanadi.
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
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
        .read<ListingRepository>()
        .myListings(limit: limit, offset: offset);
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
                    child: Text(tr('Mening eʼlonlarim'), style: OtText.display),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _paged.state.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: OtColors.accent),
                ),
                error: (message) => EmptyState(
                  icon: Icons.cloud_off,
                  title: tr('Yuklab boʻlmadi'),
                  body: message,
                  actionLabel: 'Qaytadan',
                  onAction: _paged.load,
                ),
                data: (items) => items.isEmpty
                    ? EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: tr('Eʼlonlaringiz yoʻq'),
                        body: tr('Birinchi eʼloningizni joylang — 2 daqiqa vaqt oladi.'),
                      )
                    : ListView.separated(
                        controller: _scroll,
                        padding: const EdgeInsets.all(OtSize.screenPad),
                        itemCount: items.length + 1,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: OtSize.x12),
                        itemBuilder: (_, i) => i == items.length
                            ? LoadMoreFooter(paged: _paged)
                            : _row(context, items[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, Listing l) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: l.id)),
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: OtColors.surface,
          borderRadius: BorderRadius.circular(OtSize.rCard),
          border: Border.all(color: OtColors.line),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: SizedBox(
                width: 64,
                height: 64,
                child: l.thumbUrl == null
                    ? OtPhotoPlaceholder(label: l.photoLabel)
                    : Image.network(l.thumbUrl!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OtText.cardTitle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(tr(OtFormat.listingPrice(l)), style: OtText.cardPrice),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _statusChip(l.status),
                      const SizedBox(width: 8),
                      Text(tr('${l.views} koʻrish'), style: OtText.metaSm),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(ListingStatus status) {
    final (bg, fg) = switch (status) {
      ListingStatus.active => (OtColors.accentSoft, OtColors.accentPressed),
      ListingStatus.moderation => (OtColors.warnBg, OtColors.warnIcon),
      ListingStatus.rejected => (Color(0xFFFDECEC), OtColors.danger),
      ListingStatus.expired => (OtColors.field, OtColors.inkMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        tr(status.label),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
