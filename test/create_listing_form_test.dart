import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oson_top/data/models/listing.dart';
import 'package:oson_top/data/repositories/listing_repository.dart';
import 'package:oson_top/features/create_listing/create_listing_form.dart';

void main() {
  late ListingRepository repo;
  late CreateListingForm form;

  setUp(() {
    repo = ListingRepository();
    form = CreateListingForm(repo);
  });

  test('boʻsh forma tasdiqlanmaydi va xatolarni koʻrsatadi', () {
    expect(form.validate(), isFalse);
    expect(form.photosError, 'Kamida bitta rasm qoʻshing');
    expect(form.titleError, 'Sarlavhani yozing');
    expect(form.phoneError, 'Toʻliq raqam kiriting');
  });

  test('xato matnlari tasdiqlashdan oldin koʻrinmaydi', () {
    expect(form.titleError, isNull);
    expect(form.priceError, isNull);
  });

  test('toʻldirilgan forma tasdiqlanadi', () {
    form.photos.add(XFile('/tmp/rasm.jpg'));
    form.setTitle('Yumshoq burchak divan');
    form.setPrice(3200000);
    form.setPhone('+998 90 123 45 67');

    expect(form.validate(), isTrue);
    expect(form.titleError, isNull);
  });

  test('«kelishiladi» belgilansa narx talab qilinmaydi', () {
    form.photos.add(XFile('/tmp/rasm.jpg'));
    form.setTitle('Yuk tashish xizmati');
    form.setPhone('+998 90 123 45 67');
    form.setNegotiable(true);

    expect(form.validate(), isTrue);
    expect(form.price, isNull);
    expect(form.preview().price, 0);
    expect(form.preview().isNegotiable, isTrue);
  });

  test('joylangan eʼlon moderatsiyaga tushadi va lentaga qoʻshiladi', () {
    final before = repo.all().length;

    form.photos.add(XFile('/tmp/rasm.jpg'));
    form.setTitle('Velosiped 26 oʻlcham');
    form.setPrice(950000);
    form.setPhone('+998 90 123 45 67');
    form.submit();

    expect(repo.all().length, before + 1);
    expect(repo.all().first.title, 'Velosiped 26 oʻlcham');
    expect(repo.all().first.status, ListingStatus.moderation);
  });
}
