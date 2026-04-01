import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user_entity.dart';
import '../entities/user_preferences.dart';

/// Contract for all authentication operations in the auth feature.
abstract class AuthBaseRepo {
  // ── Sign in methods ───────────────────────────────────────────────────────

  /// Sign in with Google OAuth
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign in with Apple ID (iOS/macOS only; gracefully handled on Android)
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Create a new account with email and password
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  /// Sign in anonymously as a guest user
  Future<Either<Failure, UserEntity>> signInAnonymously();

  /// Upgrade a guest account to a permanent email/password account.
  /// Retains the same UID so all data is preserved.
  Future<Either<Failure, UserEntity>> linkAnonymousAccountWithEmail({
    required String email,
    required String password,
    required String name,
  });

  // ── Session ───────────────────────────────────────────────────────────────

  /// Sign out the current user
  Future<Either<Failure, void>> signOut();

  /// Get the currently authenticated user (null if unauthenticated)
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Stream of auth state changes
  Stream<UserEntity?> get authStateChanges;

  // ── Preferences ───────────────────────────────────────────────────────────

  /// Update the user's preferences in Firestore
  Future<Either<Failure, void>> updatePreferences(UserPreferences preferences);

  /// Load preferences from Firestore for the current user
  Future<Either<Failure, UserPreferences>> getPreferences();
}
