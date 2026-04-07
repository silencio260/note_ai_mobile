import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'data/repositories/auth_repo.dart';
import 'data/repositories/mock_auth_repo.dart';
import 'domain/repositories/auth_base_repo.dart';
import 'domain/usecases/auth_usecases.dart';
import 'presentation/bloc/auth_bloc.dart';

void initAuth(GetIt sl) {
  // Check if Firebase is initialized to avoid crashes in early development
  bool isFirebaseReady = false;
  try {
    isFirebaseReady = Firebase.apps.isNotEmpty;
  } catch (_) {
    isFirebaseReady = false;
  }

  // ── External ─────────────────────────────────────────────────────────────
  if (isFirebaseReady) {
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
    sl.registerLazySingleton<GoogleSignIn>(
      () => GoogleSignIn(scopes: ['email', 'profile']),
    );

    // ── Repository ────────────────────────────────────────────────────────────
    sl.registerLazySingleton<AuthBaseRepo>(
      () => AuthRepoImpl(
        firebaseAuth: sl<FirebaseAuth>(),
        googleSignIn: sl<GoogleSignIn>(),
        firestore: sl<FirebaseFirestore>(),
      ),
    );
  } else {
    // ── Mock Fallback (For Development) ──────────────────────────────────────
    sl.registerLazySingleton<AuthBaseRepo>(() => MockAuthRepo());
    
    // Register Dummy instances to prevent GetIt from throwing 'not registered' errors
    // but Note: Accessing .instance on these will still throw if not initialized,
    // so we must ensure the app doesn't call them when isFirebaseReady is false.
  }

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl<AuthBaseRepo>()));
  sl.registerLazySingleton(() => SignInWithAppleUseCase(sl<AuthBaseRepo>()));
  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl<AuthBaseRepo>()));
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl<AuthBaseRepo>()));
  sl.registerLazySingleton(() => SignInAnonymouslyUseCase(sl<AuthBaseRepo>()));
  sl.registerLazySingleton(
      () => LinkAnonymousAccountUseCase(sl<AuthBaseRepo>()));
  sl.registerLazySingleton(() => SignOutUseCase(sl<AuthBaseRepo>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthBaseRepo>()));

  // ── BLoC ──────────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => AuthBloc(
      authRepo: sl<AuthBaseRepo>(),
      signInWithGoogle: sl<SignInWithGoogleUseCase>(),
      signInWithApple: sl<SignInWithAppleUseCase>(),
      signInWithEmail: sl<SignInWithEmailUseCase>(),
      signUpWithEmail: sl<SignUpWithEmailUseCase>(),
      signInAnonymously: sl<SignInAnonymouslyUseCase>(),
      linkAnonymousAccount: sl<LinkAnonymousAccountUseCase>(),
      signOut: sl<SignOutUseCase>(),
      getCurrentUser: sl<GetCurrentUserUseCase>(),
    ),
  );
}
