import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

import 'container_injector.dart';
import 'core/utils/app_bloc_observer.dart';
import 'my_app.dart';

void main() {
  runZonedGuarded(_bootstrap, (error, stack) {
    // TODO: Wire to firebase_crashlytics in a later phase
    debugPrint('🔴 Uncaught error: $error\n$stack');
  });
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 0. Edge-To-Edge UI ───────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
    systemStatusBarContrastEnforced: false,
  ));
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // ── 1. Hive init ──────────────────────────────────────────────────────────
  await Hive.initFlutter();
  // Hive adapters will be registered here as each feature is implemented:
  // Hive.registerAdapter(RecordingHiveModelAdapter());
  // Hive.registerAdapter(ChatSessionHiveModelAdapter());
  // Hive.registerAdapter(ChatMessageHiveModelAdapter());
  // Hive.registerAdapter(SummarizationStateHiveModelAdapter());

  // Hive boxes will be opened here:
  // await Future.wait([
  //   Hive.openBox<RecordingHiveModel>('recordings'),
  //   Hive.openBox<ChatSessionHiveModel>('chat_sessions'),
  //   Hive.openBox<ChatMessageHiveModel>('chat_messages'),
  //   Hive.openBox<SummarizationStateHiveModel>('summarization_states'),
  // ]);

  // ── 2. Firebase init ──────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── 3. StarterKit init ────────────────────────────────────────────────────
  // Uncomment after implementing AuthRepository:
  // await StarterKit.initialize(
  //   supportEmail: 'support@genrevibes.com',
  //   authRepository: sl<NoteAIAuthRepository>(),
  // );

  // ── 4. App DI Container ───────────────────────────────────────────────────
  await initApp();

  // ── 5. BLoC observer (dev only) ───────────────────────────────────────────
  Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}
