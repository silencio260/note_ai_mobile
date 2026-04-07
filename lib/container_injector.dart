import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'core/network/auth_interceptor.dart';
import 'core/network/network_info.dart';
import 'features/auth/auth_injector.dart';
import 'features/chat/chat_injector.dart';
import 'features/recording/recording_injector.dart';
import 'features/summarization/summarization_injector.dart';
import 'features/transcription/transcription_injector.dart';

/// Global service locator
final sl = GetIt.instance;

/// Root DI initializer — called before runApp()
///
/// Each feature registers via its own initXxx(sl) function.
/// Hive boxes and Firebase instances are pre-registered here as singletons.
Future<void> initApp() async {
  // ─── Core ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    if (sl.isRegistered<FirebaseAuth>()) {
      dio.interceptors.add(AuthInterceptor(sl<FirebaseAuth>()));
    }
    // Optional: Add logging interceptor during dev for debugging API calls
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    return dio;
  });

  // ─── Feature DI ──────────────────────────────────────────────────────────
  initAuth(sl);
  await initRecording(sl);
  initTranscription(sl);
  await initSummarization(sl);
  await initChat(sl);

  // Future features:
  // initSettings(sl);
}
