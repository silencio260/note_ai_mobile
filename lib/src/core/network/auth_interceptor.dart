import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Injects the Firebase ID Token into HTTP requests for backend authorization.
class AuthInterceptor extends Interceptor {
  final FirebaseAuth _auth;

  AuthInterceptor(this._auth);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final token = await user.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {
        // If getting token fails, we proceed without it. 
        // The backend will return 401 which ErrorHandler will catch.
      }
    }
    handler.next(options);
  }
}
