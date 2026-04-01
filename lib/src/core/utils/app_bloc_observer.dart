import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC observer for logging state changes during development.
/// Attach in main.dart: Bloc.observer = AppBlocObserver();
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    // ignore: avoid_print
    print('🟢 BLoC created: ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // ignore: avoid_print
    print('🔄 ${bloc.runtimeType}: ${change.currentState.runtimeType} → ${change.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    print('🔴 ${bloc.runtimeType} Error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    // ignore: avoid_print
    print('🔴 BLoC closed: ${bloc.runtimeType}');
  }
}
