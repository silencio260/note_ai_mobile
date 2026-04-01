import 'dart:io';

import 'package:dio/dio.dart';

import 'failure.dart';

/// Converts low-level exceptions into domain [Failure] objects.
/// Call [ErrorHandler.handle] in repository catch blocks.
class ErrorHandler {
  ErrorHandler._();

  static Failure handle(dynamic error) {
    if (error is DioException) return _handleDio(error);
    if (error is SocketException) return const NoInternetConnectionFailure();
    if (error is FormatException) {
      return ServerFailure('Unexpected response format: ${error.message}');
    }
    if (error is Failure) return error; // Re-throw domain failures as-is
    return ServerFailure(error.toString());
  }

  static Failure _handleDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure('Connection timed out. Please try again.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NoInternetConnectionFailure();
    }

    switch (e.response?.statusCode) {
      case 400:
        return ServerFailure(
          _extractMessage(e.response?.data) ?? 'Invalid request',
        );
      case 401:
        return const AuthFailure('Session expired. Please sign in again.');
      case 403:
        return const AuthFailure('You do not have permission for this action.');
      case 404:
        return const NotFoundFailure('The requested resource was not found.');
      case 429:
        return const ServerFailure('Too many requests. Please try again later.');
      case 500:
      case 502:
      case 503:
        return const ServerFailure(
          'Server error. Please try again in a moment.',
        );
      default:
        return ServerFailure(e.message ?? 'An unexpected network error occurred.');
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['error']?.toString() ??
          data['message']?.toString() ??
          data['detail']?.toString();
    }
    return null;
  }
}
