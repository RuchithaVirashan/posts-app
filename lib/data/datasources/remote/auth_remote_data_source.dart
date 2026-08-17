import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    final json = await _client.post(
      ApiEndpoints.login,
      data: {'username': username, 'password': password, 'expiresInMins': 30},
    );
    return AuthResponseModel.fromJson(json);
  }
}
