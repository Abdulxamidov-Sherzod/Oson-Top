import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../repositories/notifications_repository.dart';

/// Push bildirishnoma.
///
/// Firebase sozlamasi (`google-services.json` / `GoogleService-Info.plist`)
/// bo'lmasa jimgina o'chiq qoladi: ilova avvalgidek ishlayveradi, faqat push
/// kelmaydi. Shu tufayli sozlamasiz ham qurish va sinash mumkin.
abstract final class PushService {
  static bool _ready = false;
  static String? _token;

  /// Qurilmaga push kela oladimi
  static bool get isReady => _ready;

  /// Ilova ochilganda, `runApp` dan oldin chaqiriladi.
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _ready = true;
    } catch (e) {
      // Sozlama fayli yo'q yoki noto'g'ri — push'siz davom etamiz
      debugPrint('Push oʻchiq: $e');
      _ready = false;
    }
  }

  /// Kirgandan keyin: ruxsat so'raladi va token serverga yuboriladi.
  ///
  /// Ruxsat berilmasa hech narsa qilinmaydi — bildirishnomalar ilova ichida
  /// baribir ko'rinadi, chunki server ularni bazaga ham yozadi.
  static Future<void> register(NotificationsRepository repo) async {
    if (!_ready) return;

    final messaging = FirebaseMessaging.instance;
    try {
      final granted = await messaging.requestPermission();
      if (granted.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await messaging.getToken();
      if (token == null) return;
      await _save(repo, token);

      // Token vaqti-vaqti bilan almashadi
      messaging.onTokenRefresh.listen((fresh) => _save(repo, fresh));
    } catch (e) {
      debugPrint('Push roʻyxatdan oʻtmadi: $e');
    }
  }

  static Future<void> _save(NotificationsRepository repo, String token) async {
    try {
      await repo.registerDevice(token, Platform.isIOS ? 'ios' : 'android');
      _token = token;
    } catch (e) {
      debugPrint('Token saqlanmadi: $e');
    }
  }

  /// Chiqishda — bu qurilmaga boshqa push kelmasin
  static Future<void> unregister(NotificationsRepository repo) async {
    final token = _token;
    if (token == null) return;
    _token = null;
    try {
      await repo.forgetDevice(token);
    } catch (e) {
      debugPrint('Token oʻchirilmadi: $e');
    }
  }

  /// Ilova ochiq turganda kelgan xabar. Qurilma ekranida ko'rinmaydi,
  /// shuning uchun hech bo'lmasa qo'ng'iroqchadagi sonni yangilaymiz.
  static void onMessage(void Function() refresh) {
    if (!_ready) return;
    FirebaseMessaging.onMessage.listen((_) => refresh());
  }

  /// Bildirishnoma bosilganda — ochilishi kerak bo'lgan e'lon id'si
  static void onOpened(void Function(String? listingId) open) {
    if (!_ready) return;
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => open(message.data['listing_id'] as String?),
    );
    // Ilova butunlay yopiq bo'lganda bosilgan bo'lsa
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) open(message.data['listing_id'] as String?);
    });
  }
}
