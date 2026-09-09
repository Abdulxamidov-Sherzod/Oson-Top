import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Kirish tokenlari. Telefon xotirasining himoyalangan qismida saqlanadi —
/// oddiy sozlamalar faylida emas.
class TokenStore {
  static const _access = 'access_token';
  static const _refresh = 'refresh_token';

  final _storage = const FlutterSecureStorage();

  String? _cachedAccess;

  String? get cachedAccess => _cachedAccess;

  Future<String?> readAccess() async {
    _cachedAccess ??= await _storage.read(key: _access);
    return _cachedAccess;
  }

  Future<String?> readRefresh() => _storage.read(key: _refresh);

  Future<void> save({required String access, required String refresh}) async {
    _cachedAccess = access;
    await _storage.write(key: _access, value: access);
    await _storage.write(key: _refresh, value: refresh);
  }

  Future<void> clear() async {
    _cachedAccess = null;
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
  }
}
