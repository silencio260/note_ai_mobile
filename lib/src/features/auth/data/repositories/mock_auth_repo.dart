import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/auth_base_repo.dart';

class MockAuthRepo implements AuthBaseRepo {
  final _currentUser = UserEntity(
    uid: 'mock-user-123',
    email: 'dev@genrevibes.com',
    displayName: 'Development User',
    photoUrl: 'https://via.placeholder.com/150',
    isAnonymous: false,
    isEmailVerified: true,
    preferences: const UserPreferences(),
    createdAt: DateTime.now(),
  );

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(_currentUser);

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    // Return mock user for local development before Firebase is initialized
    return Right(_currentUser);
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async => Right(_currentUser);

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async => Right(_currentUser);

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async => Right(_currentUser);

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async => Right(_currentUser);

  @override
  Future<Either<Failure, UserEntity>> signInAnonymously() async => Right(_currentUser);

  @override
  Future<Either<Failure, UserEntity>> linkAnonymousAccountWithEmail({
    required String email,
    required String password,
    required String name,
  }) async => Right(_currentUser);

  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);

  @override
  Future<Either<Failure, void>> updatePreferences(UserPreferences preferences) async =>
      const Right(null);

  @override
  Future<Either<Failure, UserPreferences>> getPreferences() async =>
      const Right(UserPreferences());
}
