import 'package:dio/dio.dart';
import '../config/app_env.dart';
import 'api_response.dart';

/// A production-ready API Client that wraps Dio.
///
/// Handles common logic such as base URLs, headers, and basic error mapping
/// to [ApiResponse].
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _dio.options.baseUrl = AppEnv.cloudFunctionsBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Default headers
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Perform a GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(response.data as T, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data?['message'] ?? e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Perform a POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(response.data as T, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data?['message'] ?? e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
