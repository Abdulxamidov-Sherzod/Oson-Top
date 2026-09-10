import 'package:flutter/material.dart';

import '../../core/paged_list.dart';
import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';

/// Ro'yxat oxiriga yaqinlashganda keyingi sahifani so'raydi.
///
/// 600px oldin so'raymiz — foydalanuvchi oxiriga yetganda yangi
/// e'lonlar allaqachon joyida bo'ladi.
void attachLoadMore(ScrollController controller, VoidCallback onNeedMore) {
  controller.addListener(() {
    if (!controller.hasClients) return;
    if (controller.position.pixels >
        controller.position.maxScrollExtent - 600) {
      onNeedMore();
    }
  });
}

/// Ro'yxat tagidagi ko'rsatkich: yuklanmoqda yoki "hammasi shu".
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({
    super.key,
    required this.paged,
    this.endLabel = 'Hammasi shu',
  });

  final PagedList<dynamic> paged;
  final String endLabel;

  @override
  Widget build(BuildContext context) {
    if (paged.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.only(bottom: OtSize.x24),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: OtColors.accent,
            ),
          ),
        ),
      );
    }
    // Ro'yxat uzun bo'lsa oxiri borligini bildiramiz
    if (!paged.hasMore && paged.items.length > 8) {
      return Padding(
        padding: const EdgeInsets.only(bottom: OtSize.x24),
        child: Center(child: Text(endLabel, style: OtText.metaSm)),
      );
    }
    return const SizedBox(height: OtSize.x24);
  }
}
