import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/core/error/result.dart';
import 'package:postsapp/data/models/user_model.dart';
import 'package:postsapp/domain/repositories/auth_repository.dart';
import 'package:postsapp/presentation/auth/bloc/auth_bloc.dart';
import 'package:postsapp/presentation/auth/bloc/auth_event.dart';
import 'package:postsapp/presentation/auth/bloc/auth_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository mockRepository;

  const user = UserModel(id: 1, username: 'emilys', email: 'e@x.com');

  setUp(() {
    mockRepository = _MockAuthRepository();
  });

  group('AuthSessionRestoreRequested', () {
    blocTest<AuthBloc, AuthState>(
      'sessionRestore_withStoredSession_emitsLoadingThenAuthenticated',
      build: () {
        when(
          () => mockRepository.restoreSession(),
        ).thenAnswer((_) async => const Ok(user));
        return AuthBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const AuthSessionRestoreRequested()),
      expect: () => [const AuthLoading(), const AuthAuthenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'sessionRestore_withNoStoredSession_emitsLoadingThenUnauthenticated',
      build: () {
        when(
          () => mockRepository.restoreSession(),
        ).thenAnswer((_) async => const Ok(null));
        return AuthBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const AuthSessionRestoreRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'login_withValidCredentials_emitsLoadingThenAuthenticated',
      build: () {
        when(
          () => mockRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
            rememberMe: any(named: 'rememberMe'),
          ),
        ).thenAnswer((_) async => const Ok(user));
        return AuthBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(username: 'emilys', password: 'emilyspass'),
      ),
      expect: () => [const AuthLoading(), const AuthAuthenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'login_withInvalidCredentials_emitsLoadingThenUnauthenticatedWithFailure',
      build: () {
        when(
          () => mockRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
            rememberMe: any(named: 'rememberMe'),
          ),
        ).thenAnswer(
          (_) async => const Err(ValidationFailure('Invalid credentials')),
        );
        return AuthBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(username: 'emilys', password: 'wrong'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(
          failure: ValidationFailure('Invalid credentials'),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'login_onNetworkFailure_emitsLoadingThenUnauthenticatedWithNetworkFailure',
      build: () {
        when(
          () => mockRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
            rememberMe: any(named: 'rememberMe'),
          ),
        ).thenAnswer((_) async => const Err(NetworkFailure()));
        return AuthBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(username: 'emilys', password: 'emilyspass'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(failure: NetworkFailure()),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'login_withRememberMeFalse_passesRememberMeThroughToRepository',
      build: () {
        when(
          () => mockRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
            rememberMe: any(named: 'rememberMe'),
          ),
        ).thenAnswer((_) async => const Ok(user));
        return AuthBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          username: 'emilys',
          password: 'emilyspass',
          rememberMe: false,
        ),
      ),
      expect: () => [const AuthLoading(), const AuthAuthenticated(user)],
      verify: (_) {
        verify(
          () => mockRepository.login(
            username: 'emilys',
            password: 'emilyspass',
            rememberMe: false,
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'login_withEmptyUsername_emitsValidationFailureWithoutCallingRepository',
      build: () => AuthBloc(authRepository: mockRepository),
      act: (bloc) => bloc.add(
        const AuthLoginRequested(username: '', password: 'emilyspass'),
      ),
      expect: () => [
        const AuthUnauthenticated(
          failure: ValidationFailure('Username and password are required.'),
        ),
      ],
      verify: (_) {
        verifyNever(
          () => mockRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    blocTest<AuthBloc, AuthState>(
      'login_withEmptyPassword_emitsValidationFailureWithoutCallingRepository',
      build: () => AuthBloc(authRepository: mockRepository),
      act: (bloc) =>
          bloc.add(const AuthLoginRequested(username: 'emilys', password: '')),
      expect: () => [
        const AuthUnauthenticated(
          failure: ValidationFailure('Username and password are required.'),
        ),
      ],
      verify: (_) {
        verifyNever(
          () => mockRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        );
      },
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'logout_clearsSessionAndEmitsUnauthenticated',
      build: () {
        when(() => mockRepository.logout()).thenAnswer((_) async {});
        return AuthBloc(authRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [const AuthUnauthenticated()],
      verify: (_) {
        verify(() => mockRepository.logout()).called(1);
      },
    );
  });
}
