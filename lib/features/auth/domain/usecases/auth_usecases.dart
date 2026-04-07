import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_base_repo.dart';

class SignInWithGoogleUseCase extends BaseUseCase<UserEntity, NoParams> {
  final AuthBaseRepo _repo;
  SignInWithGoogleUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) =>
      _repo.signInWithGoogle();
}

class SignInWithAppleUseCase extends BaseUseCase<UserEntity, NoParams> {
  final AuthBaseRepo _repo;
  SignInWithAppleUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) =>
      _repo.signInWithApple();
}

// ─── Email / Password ─────────────────────────────────────────────────────────

class SignInWithEmailParams {
  final String email;
  final String password;
  const SignInWithEmailParams({required this.email, required this.password});
}

class SignInWithEmailUseCase
    extends BaseUseCase<UserEntity, SignInWithEmailParams> {
  final AuthBaseRepo _repo;
  SignInWithEmailUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithEmailParams params) =>
      _repo.signInWithEmail(email: params.email, password: params.password);
}

// ─────────────────────────────────────────────────────────────────────────────

class SignUpWithEmailParams {
  final String email;
  final String password;
  final String name;
  const SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.name,
  });
}

class SignUpWithEmailUseCase
    extends BaseUseCase<UserEntity, SignUpWithEmailParams> {
  final AuthBaseRepo _repo;
  SignUpWithEmailUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpWithEmailParams params) =>
      _repo.signUpWithEmail(
        email: params.email,
        password: params.password,
        name: params.name,
      );
}

// ─── Anonymous / Guest ────────────────────────────────────────────────────────

class SignInAnonymouslyUseCase extends BaseUseCase<UserEntity, NoParams> {
  final AuthBaseRepo _repo;
  SignInAnonymouslyUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) =>
      _repo.signInAnonymously();
}

// ─── Link Account ─────────────────────────────────────────────────────────────

class LinkAnonymousAccountParams {
  final String email;
  final String password;
  final String name;
  const LinkAnonymousAccountParams({
    required this.email,
    required this.password,
    required this.name,
  });
}

class LinkAnonymousAccountUseCase
    extends BaseUseCase<UserEntity, LinkAnonymousAccountParams> {
  final AuthBaseRepo _repo;
  LinkAnonymousAccountUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call(LinkAnonymousAccountParams params) =>
      _repo.linkAnonymousAccountWithEmail(
        email: params.email,
        password: params.password,
        name: params.name,
      );
}

// ─── Session ─────────────────────────────────────────────────────────────────

class SignOutUseCase extends BaseUseCase<void, NoParams> {
  final AuthBaseRepo _repo;
  SignOutUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(NoParams params) => _repo.signOut();
}

class GetCurrentUserUseCase extends BaseUseCase<UserEntity?, NoParams> {
  final AuthBaseRepo _repo;
  GetCurrentUserUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) =>
      _repo.getCurrentUser();
}
