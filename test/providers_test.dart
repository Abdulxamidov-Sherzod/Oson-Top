import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oson_top/app.dart';
import 'package:oson_top/data/api/api_client.dart';
import 'package:oson_top/data/api/token_store.dart';
import 'package:oson_top/data/repositories/create_listing_repository.dart';
import 'package:oson_top/data/repositories/favorites_repository.dart';
import 'package:oson_top/data/repositories/listing_repository.dart';
import 'package:oson_top/data/repositories/notifications_repository.dart';
import 'package:oson_top/data/repositories/reference_repository.dart';
import 'package:oson_top/state/auth_controller.dart';
import 'package:oson_top/state/favorites_controller.dart';
import 'package:oson_top/state/notifications_controller.dart';
import 'package:provider/provider.dart';

/// Ekranlar `context.read<T>()` bilan provayder so'raydi. Provayder
/// `app.dart` da ro'yxatdan o'tmagan bo'lsa, ilova release rejimida
/// bo'm-bo'sh ekran ko'rsatadi va sababi ko'rinmaydi — aynan shunday
/// xato "E'lon berish" oynasini qoraytirib qo'ygan edi.
void main() {
  testWidgets('ekranlar soʻraydigan provayderlar mavjud', (tester) async {
    final tokens = TokenStore();
    final api = ApiClient(tokens);

    late BuildContext ctx;
    await tester.pumpWidget(
      MultiProvider(
        providers: appProviders(api, tokens),
        child: Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    // Ilovada ishlatiladigan har bir tur
    expect(() => ctx.read<ApiClient>(), returnsNormally);
    expect(() => ctx.read<ListingRepository>(), returnsNormally);
    expect(() => ctx.read<ReferenceRepository>(), returnsNormally);
    expect(() => ctx.read<FavoritesRepository>(), returnsNormally);
    expect(() => ctx.read<CreateListingRepository>(), returnsNormally);
    expect(() => ctx.read<NotificationsRepository>(), returnsNormally);
    expect(() => ctx.read<AuthController>(), returnsNormally);
    expect(() => ctx.read<FavoritesController>(), returnsNormally);
    expect(() => ctx.read<NotificationsController>(), returnsNormally);
  });
}
