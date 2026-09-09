import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/app_notification.dart';

class NotificationsRepository {
  NotificationsRepository(this._api);

  final ApiClient _api;

  Future<List<AppNotification>> list() async {
    try {
      final resp = await _api.dio.get<dynamic>('/notifications');
      if (resp.statusCode != 200) throw ApiException.from(resp);
      return (resp.data as Map<String, dynamic>)['items']
          .cast<Map<String, dynamic>>()
          .map<AppNotification>(AppNotification.fromJson)
          .toList();
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
}
