import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes_manager.dart';
import 'config/theme_manager.dart';
import 'container_injector.dart';
import 'core/config/app_env.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/recording/presentation/bloc/audio_record_bloc.dart';
import 'features/recording/presentation/bloc/recording_bloc.dart';
import 'features/summarization/presentation/bloc/summarization_bloc.dart';
import 'features/transcription/presentation/bloc/transcription_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<RecordingBloc>(
          create: (_) => sl<RecordingBloc>(),
        ),
        BlocProvider<AudioRecordBloc>(
          create: (_) => sl<AudioRecordBloc>(),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => sl<ChatBloc>(),
        ),
        BlocProvider<SummarizationBloc>(
          create: (_) => sl<SummarizationBloc>(),
        ),
        BlocProvider<TranscriptionBloc>(
          create: (_) => sl<TranscriptionBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'NoteAI',
        debugShowCheckedModeBanner: AppEnv.developmentMode,
        theme: ThemeManager.lightTheme(),
        darkTheme: ThemeManager.darkTheme(),
        themeMode: ThemeMode.system,
        initialRoute: Routes.auth,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
