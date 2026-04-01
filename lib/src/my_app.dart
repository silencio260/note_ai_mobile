import 'package:flutter/material.dart';

import 'config/routes_manager.dart';
import 'config/theme_manager.dart';
import 'core/config/app_env.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteAI',
      debugShowCheckedModeBanner: AppEnv.developmentMode,
      theme: ThemeManager.lightTheme(),
      darkTheme: ThemeManager.darkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: Routes.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
