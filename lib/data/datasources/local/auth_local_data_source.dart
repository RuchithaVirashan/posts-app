import 'dart:convert';

import '../../../core/storage/secure_storage_service.dart';
import '../../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession({required String token, required UserModel user});

  Future<String?> getToken();

  Future<UserModel?> getCachedUser();

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    await _storage.saveToken(token);
    await _storage.saveUser(jsonEncode(user.toJson()));
  }

  @override
  Future<String?> getToken() => _storage.getToken();

  @override
  Future<UserModel?> getCachedUser() async {
    final raw = await _storage.readUser();
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> clearSession() => _storage.clear();
}
