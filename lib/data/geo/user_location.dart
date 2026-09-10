import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Foydalanuvchining hozirgi joyini aniqlash.
///
/// MapKit'ning oʻzi ruxsat soʻramaydi — `toggleUserLayer` va
/// `getUserCameraPosition` ruxsat yoʻq boʻlsa jimgina hech nima qilmaydi.
/// Shuning uchun ruxsat shu yerda, xaritadan alohida soʻraladi.
abstract final class UserLocation {
  /// Joylashuvni soʻraydi. Ruxsat berilmagan boʻlsa — soʻrab oladi.
  static Future<LocateOutcome> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocateFailed(LocateProblem.serviceOff);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocateFailed(LocateProblem.deniedForever);
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      return const LocateFailed(LocateProblem.denied);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          // Ochiq havoda ham GPS bir necha soniya oladi; binoda undan koʻp.
          // Cheksiz kutmaymiz — foydalanuvchi xaritani qoʻlda ham sura oladi.
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LocateOk(
        Point(latitude: position.latitude, longitude: position.longitude),
      );
    } catch (_) {
      return const LocateFailed(LocateProblem.notFound);
    }
  }

  /// Ruxsat butunlay yopilganda — tizim sozlamalarini ochish
  static Future<void> openSettings() => Geolocator.openAppSettings();
}

sealed class LocateOutcome {
  const LocateOutcome();
}

final class LocateOk extends LocateOutcome {
  const LocateOk(this.point);

  final Point point;
}

final class LocateFailed extends LocateOutcome {
  const LocateFailed(this.reason);

  final LocateProblem reason;
}

enum LocateProblem {
  /// Qurilmada joylashuv xizmati oʻchirilgan
  serviceOff,

  /// Foydalanuvchi soʻrovni rad etdi — keyin qayta soʻrasa boʻladi
  denied,

  /// Rad etilgan va boshqa soʻralmaydi — faqat Sozlamalardan ochiladi
  deniedForever,

  /// Ruxsat bor, lekin koordinata kelmadi (signal yoʻq yoki vaqt tugadi)
  notFound,
}
