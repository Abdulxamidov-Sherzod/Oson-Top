import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/listing_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/ot_photo_placeholder.dart';
import '../listing_detail/listing_detail_screen.dart';

/// Mening e'lonlarim. Foydalanuvchi mock — hozircha `s1` sotuvchining
/// e'lonlari ko'rsatiladi. Backend qo'shilganda haqiqiy egasi bo'yicha filtrlanadi.
class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  static const _mockOwnerId = 's1';

  @override
  Widget build(BuildContext context) {
    final items = context
        .read<ListingRepository>()
        .all()
        .where((l) => l.sellerId == _mockOwnerId)
        .toList();

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
              child: items.isEmpty
                  ? const EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'Eʼlonlaringiz yoʻq',
                      body: 'Birinchi eʼloningizni joylang — 2 daqiqa vaqt oladi.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(OtSize.screenPad),
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: OtSize.x12),
                      itemBuilder: (_, i) => _row(context, items[i]),
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
        MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: l)),
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
                child: OtPhotoPlaceholder(label: l.photoLabel),
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
