import 'package:equatable/equatable.dart';

/// A generic wrapper for all API responses in the project.
///
/// This ensures that the Data layer always returns a consistent structure
/// to the Repository layer, making error parsing and data extraction uniform.
class ApiResponse<T> extends Equatable {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  /// Factory for successful responses
  factory ApiResponse.success(T data, {int? statusCode, String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode,
      message: message,
    );
  }

  /// Factory for error responses
  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  @override
  List<Object?> get props => [success, data, message, statusCode];
}
