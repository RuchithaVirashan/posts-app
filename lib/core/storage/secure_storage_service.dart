import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/token_provider.dart';

class SecureStorageService implements TokenProvider {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveUser(String userJson) =>
      _storage.write(key: _userKey, value: userJson);

  Future<String?> readUser() => _storage.read(key: _userKey);

  Future<void> clear() =>
      Future.wait([
        _storage.delete(key: _tokenKey),
        _storage.delete(key: _userKey),
      ]);
}
