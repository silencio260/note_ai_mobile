part of 'auth_bloc.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  guest,
  loading,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState._({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.loading() : this._(status: AuthStatus.loading);

  const AuthState.authenticated(UserEntity user)
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.guest(UserEntity user)
      : this._(status: AuthStatus.guest, user: user);

  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);

  const AuthState.error(String message)
      : this._(status: AuthStatus.error, errorMessage: message);

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isGuest => status == AuthStatus.guest;
  bool get hasError => status == AuthStatus.error;

  @override
  String toString() =>
      'AuthState(status: $status, user: ${user?.uid}, error: $errorMessage)';
}
