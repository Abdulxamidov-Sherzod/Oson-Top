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
import '../create_listing/create_listing_screen.dart';
import '../listing_detail/listing_detail_screen.dart';
import '../../core/lang.dart';
import '../../shared/widgets/ot_shimmer.dart';
import '../../shared/widgets/ot_empty_art.dart';

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

  /// Amal bajarilayotgan eʼlon — qator xira boʻlib, bosilmay turadi
  String? _busyId;

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
                loading: () => const _RowSkeleton(),
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
                        art: OtEmptyArt.card,
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
    final busy = _busyId == l.id;
    return IgnorePointer(
      ignoring: busy,
      child: Opacity(
        opacity: busy ? 0.5 : 1,
        child: _rowBody(context, l),
      ),
    );
  }

  Widget _rowBody(BuildContext context, Listing l) {
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
            GestureDetector(
              onTap: () => _actions(context, l),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: OtSize.minTap,
                height: OtSize.minTap,
                child: Icon(Icons.more_horiz,
                    size: 20, color: OtColors.inkMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tahrirlash va o'chirish — qator toza qolishi uchun pastdan chiqadi
  Future<void> _actions(BuildContext context, Listing l) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: OtColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(OtSize.rSheet)),
      ),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: OtSize.x12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: OtColors.lineField,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: OtSize.x8),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: OtColors.ink),
              title: Text(tr('Tahrirlash'), style: OtText.body),
              onTap: () => Navigator.of(sheet).pop('edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: OtColors.danger),
              title: Text(tr('Oʻchirish'),
                  style: OtText.body.copyWith(color: OtColors.danger)),
              onTap: () => Navigator.of(sheet).pop('delete'),
            ),
            const SizedBox(height: OtSize.x8),
          ],
        ),
      ),
    );

    if (!context.mounted || picked == null) return;
    if (picked == 'edit') {
      await _edit(context, l);
    } else if (picked == 'delete') {
      await _delete(context, l);
    }
  }

  Future<void> _edit(BuildContext context, Listing l) async {
    final repo = context.read<ListingRepository>();
    setState(() => _busyId = l.id);
    try {
      // Ro'yxatdagi karta to'liq emas — tahrirlash uchun rasm id'lari va
      // tavsif kerak, ular faqat e'lon sahifasi javobida keladi
      final detail = await repo.byId(l.id);
      if (!context.mounted) return;
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => CreateListingScreen(editing: detail.listing),
        ),
      );
      if (saved == true) _paged.load();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('$e'))));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _delete(BuildContext context, Listing l) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: OtColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OtSize.rLg),
        ),
        title: Text(tr('Eʼlon oʻchirilsinmi?'), style: OtText.titleSm),
        content: Text(
          tr('Bu amalni orqaga qaytarib boʻlmaydi.'),
          style: OtText.body.copyWith(color: OtColors.inkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(tr('Bekor qilish'),
                style: OtText.body.copyWith(color: OtColors.inkMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(tr('Oʻchirish'),
                style: OtText.bodyStrong.copyWith(color: OtColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    setState(() => _busyId = l.id);
    try {
      await context.read<ListingRepository>().remove(l.id);
      _paged.load();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('$e'))));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
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


/// "Mening eʼlonlarim" ro'yxatining yuklanayotgandagi shakli — qatorlar
/// haqiqiysi bilan bir o'lchamda, shunda ma'lumot kelganda sakramaydi.
class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) {
    return OtShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            OtSize.screenPad, OtSize.x12, OtSize.screenPad, OtSize.x24),
        itemCount: 5,
        separatorBuilder: (_, _) => const SizedBox(height: OtSize.x12),
        itemBuilder: (_, _) => Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: OtColors.surface,
            borderRadius: BorderRadius.circular(OtSize.rCard),
            border: Border.all(color: OtColors.line),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OtSkeleton(width: 64, height: 64, radius: 11),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OtSkeleton(height: 13),
                    SizedBox(height: 8),
                    OtSkeleton(width: 108, height: 14),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        OtSkeleton(width: 66, height: 18, radius: 7),
                        SizedBox(width: 8),
                        OtSkeleton(width: 74, height: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
