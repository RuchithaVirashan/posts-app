import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/core/network/api_endpoints.dart';
import 'package:postsapp/core/network/dio_client.dart';
import 'package:postsapp/data/datasources/remote/auth_remote_data_source.dart';

class _MockDioClient extends Mock implements DioClient {}

void main() {
  late _MockDioClient mockClient;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    mockClient = _MockDioClient();
    dataSource = AuthRemoteDataSourceImpl(mockClient);
  });

  group('AuthRemoteDataSourceImpl.login', () {
    test('login_sendsUsernamePasswordAndExpiry_toLoginEndpoint', () async {
      when(
        () => mockClient.post(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => {
          'id': 1,
          'username': 'emilys',
          'email': 'e@x.com',
          'accessToken': 'jwt',
        },
      );

      await dataSource.login(username: 'emilys', password: 'emilyspass');

      final captured = verify(
        () => mockClient.post(ApiEndpoints.login, data: captureAny(named: 'data')),
      ).captured.single as Map<String, dynamic>;

      expect(captured['username'], 'emilys');
      expect(captured['password'], 'emilyspass');
      expect(captured['expiresInMins'], 30);
    });

    test('login_onSuccess_returnsParsedAuthResponse', () async {
      when(
        () => mockClient.post(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => {
          'id': 1,
          'username': 'emilys',
          'email': 'e@x.com',
          'accessToken': 'jwt-access',
        },
      );

      final response = await dataSource.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(response.accessToken, 'jwt-access');
      expect(response.user.username, 'emilys');
    });

    test('login_onInvalidCredentials_propagatesFailureFromClient', () async {
      when(
        () => mockClient.post(any(), data: any(named: 'data')),
      ).thenThrow(const ValidationFailure('Invalid credentials'));

      expect(
        () => dataSource.login(username: 'emilys', password: 'wrong'),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
