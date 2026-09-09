/// Server manzili. Ishga tushirishda o'zgartirish mumkin:
///
///     flutter run --dart-define=api=http://192.168.1.50:8000
///
/// Standart qiymat iOS simulyatori uchun — u Mac bilan bir tarmoqda.
/// Android emulyatoridan Mac'ga murojaat: http://10.0.2.2:8000
class Env {
  static const apiBase = String.fromEnvironment(
    'api',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static String get apiV1 => '$apiBase/api/v1';

  /// Rasm manzillari serverdan `/media/...` shaklida keladi
  static String media(String path) =>
      path.startsWith('http') ? path : '$apiBase$path';
}
