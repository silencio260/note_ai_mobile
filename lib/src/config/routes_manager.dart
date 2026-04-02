import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/auth_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/recording/recording_screen.dart';

/// All named route strings used for navigation
class Routes {
  Routes._();

  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String home = '/';
  static const String player = '/player';
  static const String chat = '/chat';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String record = '/record';
}

/// Route generator — called from MaterialApp.onGenerateRoute.
///
/// Each feature will replace these with real screen imports once created.
class AppRouter {
  AppRouter._();

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.auth:
        return _buildRoute(settings, const AuthScreen());
      case Routes.home:
        return _buildRoute(settings, const HomeScreen());
      case Routes.record:
        return _buildRoute(settings, const RecordingScreen());
      case Routes.player:
        final recordingId = settings.arguments as String? ?? '';
        return _buildRoute(
          settings,
          _PlaceholderScreen(title: 'Player: $recordingId'),
        );
      case Routes.chat:
        final recordingId = settings.arguments as String? ?? '';
        return _buildRoute(
          settings,
          _PlaceholderScreen(title: 'Chat: $recordingId'),
        );
      case Routes.settings:
        return _buildRoute(settings, const _PlaceholderScreen(title: 'Settings'));
      case Routes.search:
        return _buildRoute(settings, const _PlaceholderScreen(title: 'Search'));
      default:
        return _buildRoute(
          settings,
          _PlaceholderScreen(title: 'Not Found: ${settings.name}'),
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    RouteSettings settings,
    Widget page,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => page,
    );
  }
}

/// Temporary placeholder until real screens are implemented
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '🚧 $title\n(Coming soon)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
