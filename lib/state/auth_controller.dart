import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/api/api_client.dart';
import '../data/api/token_store.dart';
import '../data/models/app_user.dart';

enum AuthStatus { checking, signedOut, signedIn }

/// Kirish holati.
///
/// Kirish Telegram orqali: ilova token oladi, botni ochadi, foydalanuvchi
/// raqamini ulashadi, ilova holatni so'rab turadi.
class AuthController extends ChangeNotifier {
  AuthController(this._api, this._tokens) {
    _api.onSignedOut = signOut;
    restore();
  }

  final ApiClient _api;
  final TokenStore _tokens;

  AuthStatus status = AuthStatus.checking;
  AppUser? user;
  String? error;

  /// Telegram oynasi ochilgandan keyin holatni so'rab turadigan taymer
  Timer? _poller;
  String? _loginToken;
  bool _waiting = false;

  bool get isSignedIn => status == AuthStatus.signedIn;
  bool get isWaitingForTelegram => _waiting;

  Future<void> restore() async {
    final token = await _tokens.readAccess();
    if (token == null) {
      status = AuthStatus.signedOut;
      notifyListeners();
      return;
    }
    await loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final resp = await _api.dio.get<dynamic>('/me');
      if (resp.statusCode != 200) {
        status = AuthStatus.signedOut;
        notifyListeners();
        return;
      }
      final json = resp.data as Map<String, dynamic>;
      user = AppUser.fromJson(json);
      status = AuthStatus.signedIn;
    } on DioException {
      // Internet yo'q — tokenni o'chirmaymiz, keyin qayta urinadi
      status = AuthStatus.signedOut;
      error = 'Serverga ulanib boʻlmadi';
    }
    notifyListeners();
  }

  /// Telegram orqali kirishni boshlaydi. Ochiladigan havolani qaytaradi.
  Future<String?> startTelegramLogin() async {
    error = null;
    try {
      final resp = await _api.dio.post<dynamic>('/auth/telegram/start');
      if (resp.statusCode != 200) {
        error = ApiException.from(resp).message;
        notifyListeners();
        return null;
      }
      final json = resp.data as Map<String, dynamic>;
      _loginToken = json['token'] as String;
      _waiting = true;
      notifyListeners();
      _startPolling();
      return json['deep_link'] as String;
    } on DioException {
      error = 'Serverga ulanib boʻlmadi';
      notifyListeners();
      return null;
    }
  }

  void _startPolling() {
    _poller?.cancel();
    // Har 2 soniyada — bot bilan suhbat odatda 10-20 soniya oladi
    _poller = Timer.periodic(const Duration(seconds: 2), (_) => _check());
  }

  Future<void> _check() async {
    final token = _loginToken;
    if (token == null) return;

    try {
      final resp = await _api.dio.get<dynamic>(
        '/auth/telegram/status',
        queryParameters: {'token': token},
      );
      if (resp.statusCode != 200) return;

      final json = resp.data as Map<String, dynamic>;
      switch (json['status'] as String) {
        case 'ready':
          await _tokens.save(
            access: json['access_token'] as String,
            refresh: json['refresh_token'] as String,
          );
          cancelTelegramLogin();
          await loadProfile();
        case 'expired':
          cancelTelegramLogin();
          error = 'Havola eskirdi. Qaytadan urinib koʻring.';
          notifyListeners();
        default:
          break; // pending — kutamiz
      }
    } on DioException {
      // Vaqtinchalik uzilish — keyingi urinishda tekshiriladi
    }
  }

  void cancelTelegramLogin() {
    _poller?.cancel();
    _poller = null;
    _loginToken = null;
    _waiting = false;
    notifyListeners();
  }

  /// Telegramsiz kirish — server ALLOW_DEV_LOGIN=true bo'lganda ishlaydi
  Future<bool> devLogin(String phone) async {
    error = null;
    try {
      final resp = await _api.dio.post<dynamic>(
        '/auth/dev-login',
        data: {'phone': phone},
      );
      if (resp.statusCode != 200) {
        error = ApiException.from(resp).message;
        notifyListeners();
        return false;
      }
      final json = resp.data as Map<String, dynamic>;
      await _tokens.save(
        access: json['access_token'] as String,
        refresh: json['refresh_token'] as String,
      );
      await loadProfile();
      return true;
    } on DioException {
      error = 'Serverga ulanib boʻlmadi';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _tokens.clear();
    user = null;
    status = AuthStatus.signedOut;
    cancelTelegramLogin();
    notifyListeners();
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }
}
