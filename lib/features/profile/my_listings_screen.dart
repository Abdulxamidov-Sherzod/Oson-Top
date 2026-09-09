import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../core/async_value.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/listing_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/ot_photo_placeholder.dart';
import '../listing_detail/listing_detail_screen.dart';

/// Mening e'lonlarim. Foydalanuvchi mock — hozircha `s1` sotuvchining
/// e'lonlari ko'rsatiladi. Backend qo'shilganda haqiqiy egasi bo'yicha filtrlanadi.
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  Async<List<Listing>> _state = const Async.loading();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = const Async.loading());
    try {
      final page = await context.read<ListingRepository>().myListings();
      if (!mounted) return;
      setState(() => _state = Async.data(page.items));
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
                    child: Text('Mening eʼlonlarim', style: OtText.display),
                  ),
                ],
              ),
            ),
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
                    ? const EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'Eʼlonlaringiz yoʻq',
                        body: 'Birinchi eʼloningizni joylang — '
                            '2 daqiqa vaqt oladi.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(OtSize.screenPad),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: OtSize.x12),
                        itemBuilder: (_, i) => _row(context, items[i]),
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
                  Text(OtFormat.listingPrice(l), style: OtText.cardPrice),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _statusChip(l.status),
                      const SizedBox(width: 8),
                      Text('${l.views} koʻrish', style: OtText.metaSm),
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
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
