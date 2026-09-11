import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/listing.dart';
import '../models/seller.dart';

/// E'lonlarga yagona kirish nuqtasi. Ekranlar to'g'ridan-to'g'ri
/// serverga murojaat qilmaydi — hammasi shu klass orqali.
class ListingRepository {
  ListingRepository(this._api);

  final ApiClient _api;

  Future<Response<dynamic>> _get(String path, {Map<String, dynamic>? query}) =>
      _api.dio.get<dynamic>(path, queryParameters: query);

  Never _fail(Response<dynamic> response) => throw ApiException.from(response);

  /// Lenta va qidiruv. `q` bo'sh bo'lsa oddiy lenta qaytadi.
  Future<ListingPage> search({
    String? query,
    String? categoryId,
    String? district,
    int? priceMin,
    int? priceMax,
    String? condition,
    String sort = 'new',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final resp = await _get('/listings', query: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'category_id': ?categoryId,
        'district': ?district,
        'price_min': ?priceMin,
        'price_max': ?priceMax,
        'condition': ?condition,
        'sort': sort,
        'limit': limit,
        'offset': offset,
      });
      if (resp.statusCode != 200) _fail(resp);
      return ListingPage.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.network(e);
    }
  }

  Future<ListingDetail> byId(String id) async {
    try {
      final resp = await _get('/listings/$id');
      if (resp.statusCode != 200) _fail(resp);
      final json = resp.data as Map<String, dynamic>;
      return ListingDetail(
        listing: Listing.fromDetailJson(json),
        seller: Seller.fromJson(json['seller'] as Map<String, dynamic>),
        isFavorite: json['is_favorite'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw ApiException.network(e);
    }
  }

  /// "Raqamni koʻrsatish" bosilganda. Server sanoqni oshiradi.
  Future<String> revealPhone(String id) async {
    try {
      final resp = await _api.dio.post<dynamic>('/listings/$id/reveal-phone');
      if (resp.statusCode != 200) _fail(resp);
      return (resp.data as Map<String, dynamic>)['phone'] as String;
    } on DioException catch (e) {
      throw ApiException.network(e);
    }
  }

  Future<List<Listing>> similarTo(Listing listing, {int limit = 8}) async {
    final page = await search(categoryId: listing.categoryId, limit: limit);
    return page.items.where((l) => l.id != listing.id).toList();
  }

  Future<ListingPage> myListings({int limit = 30, int offset = 0}) async {
    try {
      final resp = await _get('/me/listings',
          query: {'limit': limit, 'offset': offset});
      if (resp.statusCode != 200) _fail(resp);
      return ListingPage.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.network(e);
    }
  }

  /// E'lonni butunlay o'chirish. Faqat egasi.
  Future<void> remove(String id) async {
    try {
      final resp = await _api.dio.delete<dynamic>('/listings/$id');
      if (resp.statusCode != 200) _fail(resp);
    } on DioException catch (e) {
      throw ApiException.network(e);
    }
  }
}

/// Sahifalangan natija
class ListingPage {
  const ListingPage({
    required this.items,
    required this.total,
    required this.offset,
    required this.limit,
  });

  factory ListingPage.fromJson(Map<String, dynamic> json) => ListingPage(
        items: (json['items'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(Listing.fromCardJson)
            .toList(),
        total: json['total'] as int,
        offset: json['offset'] as int,
        limit: json['limit'] as int,
      );

  final List<Listing> items;
  final int total;
  final int offset;
  final int limit;

  bool get hasMore => offset + items.length < total;
}

class ListingDetail {
  const ListingDetail({
    required this.listing,
    required this.seller,
    required this.isFavorite,
  });

  final Listing listing;
  final Seller seller;
  final bool isFavorite;
}
