import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/mock/mock_districts.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/listing_repository.dart';

/// E'lon berish formasining holati va tekshiruvi.
class CreateListingForm extends ChangeNotifier {
  CreateListingForm(this._repo);

  final ListingRepository _repo;
  static const maxPhotos = 8;

  final photos = <XFile>[];
  String title = '';
  String categoryId = 'phones';
  ListingCondition condition = ListingCondition.used;
  int? price;
  bool negotiable = false;
  String district = mockDistricts.first;

  /// Xaritada belgilangan aniq nuqta. Ixtiyoriy — 5-qismda to'ldiriladi.
  String? address;

  String description = '';
  String phone = '+998 ';

  bool _submitted = false;

  // ---- tekshiruv ----
  // Xato matnlari faqat "Davom etish" bosilgandan keyin ko'rinadi —
  // hali to'ldirmagan odamni qizil bilan qo'rqitmaymiz.

  String? get photosError =>
      _submitted && photos.isEmpty ? 'Kamida bitta rasm qoʻshing' : null;

  String? get titleError =>
      _submitted && title.trim().isEmpty ? 'Sarlavhani yozing' : null;

  String? get priceError => _submitted && !negotiable && (price ?? 0) <= 0
      ? 'Narxni kiriting yoki «kelishiladi» ni belgilang'
      : null;

  String? get phoneError =>
      _submitted && _phoneDigits.length < 12 ? 'Toʻliq raqam kiriting' : null;

  String get _phoneDigits => phone.replaceAll(RegExp(r'\D'), '');

  bool get isValid =>
      photos.isNotEmpty &&
      title.trim().isNotEmpty &&
      (negotiable || (price ?? 0) > 0) &&
      _phoneDigits.length >= 12;

  // ---- o'zgartirish ----

  Future<void> addPhoto(ImageSource source) async {
    if (photos.length >= maxPhotos) return;
    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final picked = await picker.pickMultiImage(limit: maxPhotos - photos.length);
      photos.addAll(picked);
    } else {
      final shot = await picker.pickImage(source: source);
      if (shot != null) photos.add(shot);
    }
    notifyListeners();
  }

  void removePhoto(int index) {
    photos.removeAt(index);
    notifyListeners();
  }

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

  void setAddress(String? v) {
    address = v;
    notifyListeners();
  }

  void setDescription(String v) => description = v;

  void setPhone(String v) {
    phone = v;
    if (_submitted) notifyListeners();
  }

  /// "Davom etish" bosilganda chaqiriladi. Xatolar bo'lsa false qaytadi.
  bool validate() {
    _submitted = true;
    notifyListeners();
    return isValid;
  }

  /// 2-qadamdagi ko'rinish uchun — hali saqlanmagan e'lon
  Listing preview() => Listing(
        id: 'draft',
        title: title.trim(),
        price: negotiable ? 0 : (price ?? 0),
        categoryId: categoryId,
        district: district,
        address: address,
        description: description.trim(),
        sellerId: 's1',
        postedAt: DateTime.now(),
        views: 0,
        condition: condition,
        photoCount: photos.length,
        photoLabel: 'rasm',
        status: ListingStatus.moderation,
      );

  /// Tasdiqlab joylash. Backend yo'q — hozircha mock ro'yxatga qo'shiladi.
  void submit() {
    final draft = preview();
    _repo.add(Listing(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      title: draft.title,
      price: draft.price,
      categoryId: draft.categoryId,
      district: draft.district,
      address: draft.address,
      description: draft.description,
      sellerId: draft.sellerId,
      postedAt: draft.postedAt,
      views: 0,
      condition: draft.condition,
      photoCount: draft.photoCount,
      photoLabel: draft.photoLabel,
      status: ListingStatus.moderation,
    ));
  }
}
