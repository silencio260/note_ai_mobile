import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/container_injector.dart';
import 'src/core/utils/app_bloc_observer.dart';
import 'src/my_app.dart';

void main() {
  runZonedGuarded(_bootstrap, (error, stack) {
    // TODO: Wire to firebase_crashlytics in a later phase
    debugPrint('🔴 Uncaught error: $error\n$stack');
  });
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  // Uncomment after running `flutterfire configure`:
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

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
