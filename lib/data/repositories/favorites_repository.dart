import 'package:dio/dio.dart';

import '../api/api_client.dart';
import 'listing_repository.dart';

class FavoritesRepository {
  FavoritesRepository(this._api);

  final ApiClient _api;

  Future<ListingPage> list({int limit = 30, int offset = 0}) async {
    try {
      final resp = await _api.dio.get<dynamic>(
        '/favorites',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (resp.statusCode != 200) throw ApiException.from(resp);
      return ListingPage.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.network(e);
    }
  }

  Future<void> add(String listingId) async {
    final resp = await _api.dio.put<dynamic>('/favorites/$listingId');
    if (resp.statusCode != 200) throw ApiException.from(resp);
  }

  Future<void> remove(String listingId) async {
    final resp = await _api.dio.delete<dynamic>('/favorites/$listingId');
    if (resp.statusCode != 200) throw ApiException.from(resp);
  }
}
