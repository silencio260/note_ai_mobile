import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes_manager.dart';
import 'config/theme_manager.dart';
import 'container_injector.dart';
import 'core/config/app_env.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
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
