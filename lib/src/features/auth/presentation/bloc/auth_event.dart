part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

class AuthSignInWithAppleRequested extends AuthEvent {
  const AuthSignInWithAppleRequested();
}

class AuthSignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInWithEmailRequested({
    required this.email,
    required this.password,
  });
}

class AuthSignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const AuthSignUpWithEmailRequested({
    required this.email,
    required this.password,
    required this.name,
  });
}

class AuthSignInAnonymouslyRequested extends AuthEvent {
  const AuthSignInAnonymouslyRequested();
}

class AuthLinkAnonymousAccountRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const AuthLinkAnonymousAccountRequested({
    required this.email,
    required this.password,
    required this.name,
  });
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthUserChanged extends AuthEvent {
  final UserEntity? user;
  const AuthUserChanged(this.user);
}
