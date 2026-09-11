import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/app_notification.dart';

class NotificationsRepository {
  NotificationsRepository(this._api);

  final ApiClient _api;

  Future<({List<AppNotification> items, int total})> list({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final resp = await _api.dio.get<dynamic>(
        '/notifications',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (resp.statusCode != 200) throw ApiException.from(resp);
      final body = resp.data as Map<String, dynamic>;
      return (
        items: (body['items'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(AppNotification.fromJson)
            .toList(),
        total: body['total'] as int,
      );
    } on DioException catch (e) {
      throw ApiException.network(e);
    }
  }

  Future<int> unreadCount() async {
    try {
      final resp = await _api.dio.get<dynamic>('/notifications/unread-count');
      if (resp.statusCode != 200) return 0;
      return (resp.data as Map<String, dynamic>)['unread'] as int;
    } on DioException catch (_) {
      return 0;
    }
  }

  Future<void> readAll() async {
    await _api.dio.post<dynamic>('/notifications/read-all');
  }

  Future<void> read(String id) async {
    await _api.dio.post<dynamic>('/notifications/$id/read');
  }

  /// Push uchun qurilma tokenini serverga saqlash
  Future<void> registerDevice(String token, String platform) async {
    await _api.dio.put<dynamic>(
      '/me/devices',
      data: {'token': token, 'platform': platform},
    );
  }

  /// Chiqishda — bu qurilmaga endi push kelmasin
  Future<void> forgetDevice(String token) async {
    await _api.dio.delete<dynamic>('/me/devices/$token');
  }
}
