import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'data/repositories/auth_repo.dart';
import 'domain/repositories/auth_base_repo.dart';
import 'domain/usecases/auth_usecases.dart';
import 'presentation/bloc/auth_bloc.dart';

void initAuth(GetIt sl) {
  // ── External ─────────────────────────────────────────────────────────────
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
