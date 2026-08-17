import '../../core/error/failures.dart';
import '../../core/error/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_data_source.dart';
import '../datasources/remote/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Result<User>> login({
    required String username,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      final response = await _remote.login(
        username: username,
        password: password,
      );
      if (rememberMe) {
        await _local.saveSession(
          token: response.accessToken,
          user: response.user,
        );
      }
      return Ok(response.user);
    } on Failure catch (failure) {
      return Err(failure);
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<User?>> restoreSession() async {
    try {
      final token = await _local.getToken();
      final user = await _local.getCachedUser();
      if (token == null || token.isEmpty || user == null) {
        return const Ok(null);
      }
      return Ok(user);
    } catch (_) {
      return const Ok(null);
    }
  }

  @override
  Future<void> logout() => _local.clearSession();
}
