import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/data/datasources/local/auth_local_data_source.dart';
import 'package:postsapp/data/datasources/remote/auth_remote_data_source.dart';
import 'package:postsapp/data/models/auth_response_model.dart';
import 'package:postsapp/data/models/user_model.dart';
import 'package:postsapp/data/repositories/auth_repository_impl.dart';

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late _MockAuthRemoteDataSource mockRemote;
  late _MockAuthLocalDataSource mockLocal;
  late AuthRepositoryImpl repository;

  const user = UserModel(id: 1, username: 'emilys', email: 'e@x.com');

  setUpAll(() {
    registerFallbackValue(user);
  });

  setUp(() {
    mockRemote = _MockAuthRemoteDataSource();
    mockLocal = _MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(remote: mockRemote, local: mockLocal);
  });

  group('login', () {
    test('login_withValidCredentials_returnsUserAndStoresToken', () async {
      when(
        () => mockRemote.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const AuthResponseModel(user: user, accessToken: 'jwt'),
      );
      when(
        () => mockLocal.saveSession(
          token: any(named: 'token'),
          user: any(named: 'user'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(result.isOk, isTrue);
      result.when(
        ok: (u) => expect(u, user),
        err: (_) => fail('expected Ok'),
      );
      verify(
        () => mockLocal.saveSession(token: 'jwt', user: user),
      ).called(1);
    });

    test('login_withRememberMeFalse_returnsUserWithoutPersistingSession', () async {
      when(
        () => mockRemote.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const AuthResponseModel(user: user, accessToken: 'jwt'),
      );

      final result = await repository.login(
        username: 'emilys',
        password: 'emilyspass',
        rememberMe: false,
      );

      result.when(
        ok: (u) => expect(u, user),
        err: (_) => fail('expected Ok'),
      );
      verifyNever(
        () => mockLocal.saveSession(
          token: any(named: 'token'),
          user: any(named: 'user'),
        ),
      );
    });

    test('login_withInvalidCredentials_returnsFailureAndDoesNotPersist', () async {
      when(
        () => mockRemote.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const ValidationFailure('Invalid credentials'));

      final result = await repository.login(
        username: 'emilys',
        password: 'wrong',
      );

      expect(result.isErr, isTrue);
      result.when(
        ok: (_) => fail('expected Err'),
        err: (failure) => expect(failure, isA<ValidationFailure>()),
      );
      verifyNever(
        () => mockLocal.saveSession(
          token: any(named: 'token'),
          user: any(named: 'user'),
        ),
      );
    });

    test('login_onNetworkFailure_returnsNetworkFailure', () async {
      when(
        () => mockRemote.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const NetworkFailure());

      final result = await repository.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      result.when(
        ok: (_) => fail('expected Err'),
        err: (failure) => expect(failure, isA<NetworkFailure>()),
      );
    });

    test('login_onUnexpectedException_returnsUnknownFailure', () async {
      when(
        () => mockRemote.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('boom'));

      final result = await repository.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      result.when(
        ok: (_) => fail('expected Err'),
        err: (failure) => expect(failure, isA<UnknownFailure>()),
      );
    });
  });

  group('restoreSession', () {
    test('restoreSession_withStoredTokenAndUser_returnsUser', () async {
      when(() => mockLocal.getToken()).thenAnswer((_) async => 'jwt');
      when(() => mockLocal.getCachedUser()).thenAnswer((_) async => user);

      final result = await repository.restoreSession();

      result.when(
        ok: (u) => expect(u, user),
        err: (_) => fail('expected Ok'),
      );
    });

    test('restoreSession_withNoStoredToken_returnsOkNull', () async {
      when(() => mockLocal.getToken()).thenAnswer((_) async => null);
      when(() => mockLocal.getCachedUser()).thenAnswer((_) async => user);

      final result = await repository.restoreSession();

      result.when(
        ok: (u) => expect(u, isNull),
        err: (_) => fail('expected Ok(null)'),
      );
    });

    test('restoreSession_withNoStoredUser_returnsOkNull', () async {
      when(() => mockLocal.getToken()).thenAnswer((_) async => 'jwt');
      when(() => mockLocal.getCachedUser()).thenAnswer((_) async => null);

      final result = await repository.restoreSession();

      result.when(
        ok: (u) => expect(u, isNull),
        err: (_) => fail('expected Ok(null)'),
      );
    });
  });

  group('logout', () {
    test('logout_clearsLocalSession', () async {
      when(() => mockLocal.clearSession()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockLocal.clearSession()).called(1);
    });
  });
}
