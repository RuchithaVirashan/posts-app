import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<AuthSessionRestoreRequested>(_onSessionRestoreRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onSessionRestoreRequested(
    AuthSessionRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authRepository.restoreSession();
    result.when(
      ok: (user) => emit(
        user != null ? AuthAuthenticated(user) : const AuthUnauthenticated(),
      ),
      err: (failure) => emit(AuthUnauthenticated(failure: failure)),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final username = event.username.trim();
    final password = event.password;

    if (username.isEmpty || password.isEmpty) {
      emit(
        const AuthUnauthenticated(
          failure: ValidationFailure('Username and password are required.'),
        ),
      );
      return;
    }

    emit(const AuthLoading());
    final result = await _authRepository.login(
      username: username,
      password: password,
      rememberMe: event.rememberMe,
    );
    result.when(
      ok: (user) => emit(AuthAuthenticated(user)),
      err: (failure) => emit(AuthUnauthenticated(failure: failure)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
