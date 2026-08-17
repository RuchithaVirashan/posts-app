import '../../core/error/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login({
    required String username,
    required String password,
    bool rememberMe = true,
  });

  Future<Result<User?>> restoreSession();

  Future<void> logout();
}
