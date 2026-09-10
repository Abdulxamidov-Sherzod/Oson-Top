import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../core/theme/ot_colors.dart';
import '../../core/theme/ot_sizes.dart';
import '../../core/theme/ot_text.dart';

/// E'londagi joylashuv kartasi: xarita, markazda pin va manzil.
///
/// Xarita bosilmaydi — barmoq bilan surilganda sahifa scroll'i bilan
/// urishmasin. Bosilganda Yandex Maps ilovasi ochiladi.
class LocationMapCard extends StatelessWidget {
  const LocationMapCard({
    super.key,
    required this.lat,
    required this.lng,
    required this.district,
    this.address,
    this.height = 150,
    this.zoom = 15.5,
    this.onTap,
  });

  final double lat;
  final double lng;
  final String district;
  final String? address;
  final double height;
  final double zoom;

  /// Berilmasa — Yandex Maps ochiladi
  final VoidCallback? onTap;

  Future<void> _openInMaps() async {
    // Avval ilova, bo'lmasa brauzer
    final app = Uri.parse('yandexmaps://maps.yandex.ru/?pt=$lng,$lat&z=16');
    if (await canLaunchUrl(app)) {
      await launchUrl(app, mode: LaunchMode.externalApplication);
      return;
    }
    final web = Uri.parse('https://yandex.uz/maps/?pt=$lng,$lat&z=16&l=map');
    if (await canLaunchUrl(web)) {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? _openInMaps,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(OtSize.rCard),
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: YandexMap(
                    tiltGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    onMapCreated: (controller) async {
                      // Widget joylashib bo'lgach ko'chiramiz — aks holda
                      // xarita hali o'lchamsiz va ko'chirish e'tiborsiz qoladi
                      await WidgetsBinding.instance.endOfFrame;
                      await controller.moveCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: Point(latitude: lat, longitude: lng),
                            zoom: zoom,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Pin markazda — xarita ham shu nuqtaga qaratilgan
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: height * 0.16),
                  child: const Icon(Icons.location_on,
                      size: 38, color: OtColors.accent),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: _addressBar(),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(OtSize.rCard),
                    border: Border.all(color: OtColors.lineStrong),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addressBar() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: OtColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(11),
        boxShadow: const [
          BoxShadow(
            color: OtColors.liftShadow,
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.place_outlined, size: 15, color: OtColors.accent),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              address == null ? district : '$district, $address',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: OtColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(onTap == null ? 'Xaritada ochish' : 'Oʻzgartirish',
              style: OtText.link),
        ],
      ),
    );
  }
}
