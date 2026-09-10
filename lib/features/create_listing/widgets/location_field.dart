import 'package:flutter/material.dart';

import '../../../core/theme/ot_colors.dart';
import '../../../core/theme/ot_sizes.dart';
import '../../../core/theme/ot_text.dart';
import '../../../shared/widgets/location_map_card.dart';

/// Joylashuv: tuman (majburiy) + xaritada aniq nuqta (ixtiyoriy).
///
/// Xaritaning o'zi formada bosilmaydi — bosilganda alohida ekran ochiladi.
/// Sabab: mobil formada inline xarita sahifa scroll'i bilan urishadi.
class LocationField extends StatelessWidget {
  const LocationField({
    super.key,
    required this.district,
    required this.address,
    required this.onDistrictTap,
    required this.onMapTap,
    required this.onClear,
    this.lat,
    this.lng,
  });

  final String district;
  final String? address;
  final double? lat;
  final double? lng;
  final VoidCallback onDistrictTap;
  final VoidCallback onMapTap;
  final VoidCallback onClear;

  bool get _hasPoint => lat != null && lng != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Joylashuv', style: OtText.label),
        const SizedBox(height: 7),
        GestureDetector(
          onTap: onDistrictTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: OtSize.field,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: OtColors.field,
              borderRadius: BorderRadius.circular(OtSize.rMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.place_outlined,
                    size: 15, color: OtColors.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(district,
                      style: const TextStyle(
                          fontSize: 15, color: OtColors.ink)),
                ),
                const Icon(Icons.expand_more,
                    size: 18, color: OtColors.inkMuted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_hasPoint)
          Stack(
            children: [
              LocationMapCard(
                lat: lat!,
                lng: lng!,
                district: district,
                address: address,
                height: 110,
                zoom: 16,
                onTap: onMapTap,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: OtColors.surface.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Text('Olib tashlash',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: OtColors.inkMuted,
                        )),
                  ),
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: onMapTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: OtSize.field,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: OtColors.surface,
                borderRadius: BorderRadius.circular(OtSize.rMd),
                border: Border.all(color: OtColors.lineField),
              ),
              child: const Row(
                children: [
                  Icon(Icons.map_outlined, size: 17, color: OtColors.accent),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text('Xaritada belgilash',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: OtColors.accent,
                        )),
                  ),
                  Icon(Icons.chevron_right,
                      size: 18, color: OtColors.dividerDot),
                ],
              ),
            ),
          ),
        const SizedBox(height: 7),
        const Text(
          'Aniq nuqta ixtiyoriy — faqat tumanni qoldirsangiz ham boʻladi.',
          style: OtText.metaSm,
        ),
      ],
    );
  }
}
