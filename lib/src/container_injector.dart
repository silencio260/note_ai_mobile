import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import 'core/network/network_info.dart';
import 'features/auth/auth_injector.dart';

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

  // ─── Feature DI ──────────────────────────────────────────────────────────
  initAuth(sl);

  // Future features:
  // initRecording(sl);
  // initTranscription(sl);
  // initSummarization(sl);
  // initChat(sl);
  // initSettings(sl);
}
