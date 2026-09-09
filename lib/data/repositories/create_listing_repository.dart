import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_client.dart';
import '../models/listing.dart';

/// E'lon joylash: rasmlarni yuklash va e'lonni yaratish.
class CreateListingRepository {
  CreateListingRepository(this._api);

  final ApiClient _api;

  /// Rasm forma to'ldirilayotganda yuklanadi — e'lon yaratilganda faqat
  /// id'lar yuboriladi, shunda "Joylash" tugmasi tez ishlaydi.
  Future<int> uploadPhoto(XFile file) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.name),
      });
      final resp = await _api.dio.post<dynamic>('/photos', data: form);
      if (resp.statusCode != 201) throw ApiException.from(resp);
      return (resp.data as Map<String, dynamic>)['id'] as int;
    } on DioException catch (e) {
      throw ApiException.network(e);
    }
  }

  Future<Listing> create({
    required String title,
    required String description,
    required int price,
    String? priceUnit,
    required String categoryId,
    required String condition,
    required String district,
    String? address,
    double? lat,
    double? lng,
    required List<int> photoIds,
    List<(String, String)> specs = const [],
  }) async {
    try {
      final resp = await _api.dio.post<dynamic>('/listings', data: {
        'title': title,
        'description': description,
        'price': price,
        'price_unit': ?priceUnit,
        'category_id': categoryId,
        'condition': condition,
        'district': district,
        'address': ?address,
        'lat': ?lat,
        'lng': ?lng,
        'photo_ids': photoIds,
        'specs': [
          for (final (label, value) in specs)
            {'label': label, 'value': value},
        ],
      });
      if (resp.statusCode != 201) throw ApiException.from(resp);
      return Listing.fromDetailJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.network(e);
    }
  }
}
