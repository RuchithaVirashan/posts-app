import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthSessionRestoreRequested extends AuthEvent {
  const AuthSessionRestoreRequested();
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.username,
    required this.password,
    this.rememberMe = true,
  });

  final String username;
  final String password;
  final bool rememberMe;

  @override
  List<Object?> get props => [username, password, rememberMe];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
