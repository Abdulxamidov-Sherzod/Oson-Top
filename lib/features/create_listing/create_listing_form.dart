import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/listing.dart';
import '../../data/repositories/create_listing_repository.dart';
import '../../core/lang.dart';

/// Bitta rasm. Yangi tanlangani — telefondagi fayl, tahrirlashda kelgani esa
/// allaqachon serverda turgan rasm (fayli yo'q, faqat havolasi bor).
class PickedPhoto {
  PickedPhoto(XFile this.file)
      : url = null,
        uploading = true;

  /// Tahrirlashda: e'londa allaqachon turgan rasm
  PickedPhoto.uploaded({required int id, required this.url})
      : file = null,
        uploading = false {
    remoteId = id;
  }

  final XFile? file;
  final String? url;
  int? remoteId;
  bool uploading;
  String? error;

  bool get isReady => remoteId != null;
}

/// E'lon berish formasining holati, tekshiruvi va serverga yuborilishi.
///
/// Tahrirlashda ham shu forma ishlatiladi — `editing` berilsa maydonlar
/// to'ldirilgan holda ochiladi va yuborilganda yangi e'lon yaratilmaydi.
class CreateListingForm extends ChangeNotifier {
  CreateListingForm(this._repo, {required this.districts, Listing? editing})
      : editingId = editing?.id {
    if (editing != null) _seed(editing);
  }

  final CreateListingRepository _repo;
  final List<String> districts;

  /// null bo'lsa — yangi e'lon
  final String? editingId;

  bool get isEditing => editingId != null;

  void _seed(Listing l) {
    title = l.title;
    categoryId = l.categoryId;
    condition = l.condition;
    negotiable = l.price == 0;
    price = l.price == 0 ? null : l.price;
    district = l.district;
    address = l.address;
    lat = l.lat;
    lng = l.lng;
    description = l.description;
    for (var i = 0; i < l.photoIds.length; i++) {
      photos.add(PickedPhoto.uploaded(
        id: l.photoIds[i],
        url: i < l.photoUrls.length ? l.photoUrls[i] : null,
      ));
    }
  }

  static const maxPhotos = 8;

  final photos = <PickedPhoto>[];
  String title = '';
  String categoryId = 'phones';
  ListingCondition condition = ListingCondition.used;
  int? price;
  bool negotiable = false;
  late String district = districts.isEmpty ? '' : districts.first;
  String? address;
  double? lat;
  double? lng;
  String description = '';
  String phone = '';

  bool _submitted = false;
  bool submitting = false;
  String? submitError;

  /// Yuborilgandan keyin serverdagi holat. Tahrirlashda muhim: matn yoki
  /// rasm oʻzgargan boʻlsa eʼlon qaytadan moderatsiyaga tushadi.
  ListingStatus? resultStatus;

  // ---- tekshiruv ----
  // Xato matnlari faqat "Davom etish" bosilgandan keyin ko'rinadi

  String? get photosError {
    if (!_submitted) return null;
    if (photos.isEmpty) return tr('Kamida bitta rasm qoʻshing');
    if (photos.any((p) => p.uploading)) return tr('Rasmlar yuklanmoqda, kuting');
    if (photos.every((p) => !p.isReady)) return tr('Rasm yuklanmadi, qaytadan urining');
    return null;
  }

  String? get titleError =>
      _submitted && title.trim().length < 3 ? tr('Sarlavhani yozing') : null;

  String? get priceError => _submitted && !negotiable && (price ?? 0) <= 0
      ? tr('Narxni kiriting yoki «kelishiladi» ni belgilang')
      : null;

  bool get isValid =>
      photos.any((p) => p.isReady) &&
      !photos.any((p) => p.uploading) &&
      title.trim().length >= 3 &&
      (negotiable || (price ?? 0) > 0);

  // ---- rasmlar ----

  Future<void> addPhotos(ImageSource source) async {
    final picker = ImagePicker();
    final picked = <XFile>[];

    if (source == ImageSource.gallery) {
      picked.addAll(
        await picker.pickMultiImage(limit: maxPhotos - photos.length),
      );
    } else {
      final shot = await picker.pickImage(source: source);
      if (shot != null) picked.add(shot);
    }

    for (final file in picked.take(maxPhotos - photos.length)) {
      final photo = PickedPhoto(file);
      photos.add(photo);
      notifyListeners();
      _upload(photo);
    }
  }

  Future<void> _upload(PickedPhoto photo) async {
    try {
      photo.remoteId = await _repo.uploadPhoto(photo.file!);
      photo.error = null;
    } catch (e) {
      photo.error = '$e';
    }
    photo.uploading = false;
    notifyListeners();
  }

  void removePhoto(int index) {
    photos.removeAt(index);
    notifyListeners();
  }

  void retryPhoto(int index) {
    final photo = photos[index];
    photo
      ..uploading = true
      ..error = null;
    notifyListeners();
    _upload(photo);
  }

  // ---- maydonlar ----

  void setTitle(String v) {
    title = v;
    if (_submitted) notifyListeners();
  }

  void setCategory(String v) {
    categoryId = v;
    notifyListeners();
  }

  void setCondition(ListingCondition v) {
    condition = v;
    notifyListeners();
  }

  void setPrice(int? v) {
    price = v;
    if (_submitted) notifyListeners();
  }

  void setNegotiable(bool v) {
    negotiable = v;
    if (v) price = null;
    notifyListeners();
  }

  void setDistrict(String v) {
    district = v;
    notifyListeners();
  }

  void setPoint({String? address, double? lat, double? lng}) {
    this.address = address;
    this.lat = lat;
    this.lng = lng;
    notifyListeners();
  }

  void setDescription(String v) => description = v;

  bool validate() {
    _submitted = true;
    notifyListeners();
    return isValid;
  }

  /// 2-qadamdagi karta ko'rinishi uchun — hali saqlanmagan e'lon
  Listing preview() => Listing(
        id: 'draft',
        title: title.trim(),
        price: negotiable ? 0 : (price ?? 0),
        categoryId: categoryId,
        district: district,
        address: address,
        lat: lat,
        lng: lng,
        description: description.trim(),
        sellerId: '',
        postedAt: DateTime.now(),
        views: 0,
        condition: condition,
        photoCount: photos.length,
        status: ListingStatus.moderation,
      );

  String get _conditionCode => switch (condition) {
        ListingCondition.fresh => 'fresh',
        ListingCondition.used => 'used',
        ListingCondition.none => 'none',
      };

  Future<bool> submit() async {
    submitting = true;
    submitError = null;
    notifyListeners();

    final photoIds = [
      for (final p in photos)
        if (p.remoteId != null) p.remoteId!,
    ];

    try {
      if (isEditing) {
        final saved = await _repo.update(
          editingId!,
          title: title.trim(),
          description: description.trim(),
          price: negotiable ? 0 : (price ?? 0),
          categoryId: categoryId,
          condition: _conditionCode,
          district: district,
          address: address,
          lat: lat,
          lng: lng,
          photoIds: photoIds,
        );
        resultStatus = saved.status;
        submitting = false;
        notifyListeners();
        return true;
      }

      final created = await _repo.create(
        title: title.trim(),
        description: description.trim(),
        price: negotiable ? 0 : (price ?? 0),
        categoryId: categoryId,
        condition: _conditionCode,
        district: district,
        address: address,
        lat: lat,
        lng: lng,
        photoIds: photoIds,
      );
      resultStatus = created.status;
      submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      submitError = '$e';
      submitting = false;
      notifyListeners();
      return false;
    }
  }
}
