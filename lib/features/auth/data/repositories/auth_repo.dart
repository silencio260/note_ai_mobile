import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/auth_base_repo.dart';
import '../models/user_model.dart';

class AuthRepoImpl implements AuthBaseRepo {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepoImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firestore = firestore;

  // ─── Helpers ──────────────────────────────────────────────────────────────

  CollectionReference get _users => _firestore.collection('users');

  Future<UserModel> _saveUserToFirestore(User firebaseUser) async {
    final ref = _users.doc(firebaseUser.uid);
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      final model = UserModel.fromFirebaseUser(firebaseUser);
      await ref.set(model.toMap());
      return model;
    }

    // Merge — update mutable fields without overwriting preferences
    final existing = UserModel.fromMap(snapshot.data()! as Map<String, dynamic>);
    final updated = UserModel(
      uid: existing.uid,
      email: firebaseUser.email ?? existing.email,
      displayName: firebaseUser.displayName ?? existing.displayName,
      photoUrl: firebaseUser.photoURL ?? existing.photoUrl,
      isAnonymous: firebaseUser.isAnonymous,
      isEmailVerified: firebaseUser.emailVerified,
      preferences: existing.preferences,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    await ref.update({
      'displayName': updated.displayName,
      'photoUrl': updated.photoUrl,
      'isAnonymous': updated.isAnonymous,
      'isEmailVerified': updated.isEmailVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return updated;
  }

  // ─── Auth State ───────────────────────────────────────────────────────────

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        final model = await _saveUserToFirestore(user);
        return model.toEntity();
      } catch (_) {
        return UserModel.fromFirebaseUser(user).toEntity();
      }
    });
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return const Right(null);
      final model = await _saveUserToFirestore(user);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ─── Google ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left(AuthFailure('Google sign in was cancelled'));
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final model = await _saveUserToFirestore(userCredential.user!);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ─── Apple ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);

      // Apple sometimes returns null displayName on re-auth — keep existing
      final user = userCredential.user!;
      if (appleCredential.givenName != null && user.displayName == null) {
        final name =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}';
        await user.updateDisplayName(name.trim());
        await user.reload();
      }
      final model = await _saveUserToFirestore(
        _firebaseAuth.currentUser!,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ─── Email / Password ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final model = await _saveUserToFirestore(credential.user!);
      return Right(model.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(name);
      await credential.user!.reload();
      final model = await _saveUserToFirestore(_firebaseAuth.currentUser!);
      return Right(model.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ─── Anonymous ────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      final model = await _saveUserToFirestore(credential.user!);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ─── Link Account ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserEntity>> linkAnonymousAccountWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || !user.isAnonymous) {
        return const Left(AuthFailure('No anonymous user to link'));
      }

      final emailCred = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final linked = await user.linkWithCredential(emailCred);
      await linked.user!.updateDisplayName(name);
      await linked.user!.reload();
      final model = await _saveUserToFirestore(_firebaseAuth.currentUser!);
      return Right(model.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ─── Preferences ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> updatePreferences(
      UserPreferences preferences) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) return const Left(AuthFailure('Not authenticated'));
      await _users.doc(uid).update({'preferences': preferences.toMap()});
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, UserPreferences>> getPreferences() async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) {
        return const Right(UserPreferences());
      }
      final doc = await _users.doc(uid).get();
      if (!doc.exists) return const Right(UserPreferences());
      final data = doc.data()! as Map<String, dynamic>;
      final prefMap = data['preferences'] as Map<String, dynamic>? ?? {};
      return Right(UserPreferences.fromMap(prefMap));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ─── Error mapping ────────────────────────────────────────────────────────

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email. Please sign up.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'credential-already-in-use':
        return 'This account is already linked to another user.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
