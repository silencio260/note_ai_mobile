import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_base_repo.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../../core/usecase/base_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthBaseRepo _authRepo;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignInWithAppleUseCase _signInWithApple;
  final SignInWithEmailUseCase _signInWithEmail;
  final SignUpWithEmailUseCase _signUpWithEmail;
  final SignInAnonymouslyUseCase _signInAnonymously;
  final LinkAnonymousAccountUseCase _linkAnonymousAccount;
  final SignOutUseCase _signOut;
  final GetCurrentUserUseCase _getCurrentUser;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required AuthBaseRepo authRepo,
    required SignInWithGoogleUseCase signInWithGoogle,
    required SignInWithAppleUseCase signInWithApple,
    required SignInWithEmailUseCase signInWithEmail,
    required SignUpWithEmailUseCase signUpWithEmail,
    required SignInAnonymouslyUseCase signInAnonymously,
    required LinkAnonymousAccountUseCase linkAnonymousAccount,
    required SignOutUseCase signOut,
    required GetCurrentUserUseCase getCurrentUser,
  })  : _authRepo = authRepo,
        _signInWithGoogle = signInWithGoogle,
        _signInWithApple = signInWithApple,
        _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signInAnonymously = signInAnonymously,
        _linkAnonymousAccount = linkAnonymousAccount,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        super(const AuthState.unknown()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthSignInWithAppleRequested>(_onSignInWithApple);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmail);
    on<AuthSignUpWithEmailRequested>(_onSignUpWithEmail);
    on<AuthSignInAnonymouslyRequested>(_onSignInAnonymously);
    on<AuthLinkAnonymousAccountRequested>(_onLinkAnonymousAccount);
    on<AuthSignOutRequested>(_onSignOut);

    // Subscribe to auth state changes
    _authStateSubscription = _authRepo.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  // ─── Handlers ─────────────────────────────────────────────────────────────

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _getCurrentUser(const NoParams());
    result.fold(
      (failure) => emit(const AuthState.unauthenticated()),
      (user) => emit(_stateFromUser(user)),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(_stateFromUser(event.user));
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _signInWithGoogle(const NoParams());
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(_stateFromUser(user)),
    );
  }

  Future<void> _onSignInWithApple(
    AuthSignInWithAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _signInWithApple(const NoParams());
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(_stateFromUser(user)),
    );
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _signInWithEmail(
      SignInWithEmailParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(_stateFromUser(user)),
    );
  }

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _signUpWithEmail(
      SignUpWithEmailParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(_stateFromUser(user)),
    );
  }

  Future<void> _onSignInAnonymously(
    AuthSignInAnonymouslyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _signInAnonymously(const NoParams());
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.guest(user)),
    );
  }

  Future<void> _onLinkAnonymousAccount(
    AuthLinkAnonymousAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _linkAnonymousAccount(
      LinkAnonymousAccountParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    await _signOut(const NoParams());
    emit(const AuthState.unauthenticated());
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  AuthState _stateFromUser(UserEntity? user) {
    if (user == null) return const AuthState.unauthenticated();
    if (user.isAnonymous) return AuthState.guest(user);
    return AuthState.authenticated(user);
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
