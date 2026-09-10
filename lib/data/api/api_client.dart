import 'dart:async';

import 'package:dio/dio.dart';

import '../../core/env.dart';
import 'token_store.dart';
import '../../core/lang.dart';

/// Server bilan aloqa. Token qo'shish va eskirganda yangilash shu yerda —
/// ekranlar bu haqda bilmaydi.
class ApiClient {
  ApiClient(this.tokens) {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.apiV1,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        // Xatolarni o'zimiz hal qilamiz
        validateStatus: (code) => code != null && code < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokens.readAccess();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          // Access token eskirgan — refresh bilan yangilab, so'rovni takrorlaymiz
          if (response.statusCode == 401 && !_isAuthPath(response.requestOptions)) {
            final renewed = await _refresh();
            if (renewed) {
              try {
                final retried = await _retry(response.requestOptions);
                return handler.resolve(retried);
              } on DioException catch (_) {
                // Takror ham ishlamadi — 401 ni o'zini qaytaramiz
              }
            } else {
              onSignedOut?.call();
            }
          }
          handler.next(response);
        },
      ),
    );
  }

  late final Dio dio;
  final TokenStore tokens;

  /// Refresh ham eskirganda chaqiriladi — ilova kirish ekraniga qaytadi
  void Function()? onSignedOut;

  Completer<bool>? _refreshing;

  bool _isAuthPath(RequestOptions options) =>
      options.path.startsWith('/auth/');

  /// Bir vaqtda bir nechta so'rov 401 olsa, refresh faqat bir marta ketadi
  Future<bool> _refresh() {
    if (_refreshing != null) return _refreshing!.future;

    final completer = Completer<bool>();
    _refreshing = completer;

    () async {
      try {
        final refresh = await tokens.readRefresh();
        if (refresh == null) {
          completer.complete(false);
          return;
        }
        final fresh = Dio(BaseOptions(baseUrl: Env.apiV1));
        final resp = await fresh.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refresh_token': refresh},
          options: Options(validateStatus: (c) => c != null && c < 500),
        );
        if (resp.statusCode != 200 || resp.data == null) {
          await tokens.clear();
          completer.complete(false);
          return;
        }
        await tokens.save(
          access: resp.data!['access_token'] as String,
          refresh: resp.data!['refresh_token'] as String,
        );
        completer.complete(true);
      } catch (_) {
        completer.complete(false);
      } finally {
        _refreshing = null;
      }
    }();

    return completer.future;
  }

  Future<Response<dynamic>> _retry(RequestOptions options) {
    return dio.fetch<dynamic>(
      options..headers['Authorization'] = 'Bearer ${tokens.cachedAccess}',
    );
  }
}

/// Serverdan kelgan xato. Ekranlar shu matnni ko'rsatadi.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;

  /// FastAPI xatoni `{"detail": "..."}` yoki validatsiya ro'yxati sifatida
  /// qaytaradi — ikkalasini ham o'qiymiz.
  static ApiException from(Response<dynamic> response) {
    final data = response.data;
    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      if (detail is String) {
        return ApiException(detail, statusCode: response.statusCode);
      }
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          return ApiException('${first['msg']}', statusCode: response.statusCode);
        }
      }
    }
    return ApiException(
      tr('Serverda xatolik yuz berdi'),
      statusCode: response.statusCode,
    );
  }

  static ApiException network([Object? error]) => ApiException(
        tr('Internetga ulanib boʻlmadi. Aloqani tekshiring.'),
      );
}
