import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../../../core/config/app_env.dart';

abstract class SummarizationRemoteDataSource {
  Future<String> summarizeText(String text);
}

class SummarizationRemoteDataSourceImpl
    implements SummarizationRemoteDataSource {
  final Dio _dio;

  SummarizationRemoteDataSourceImpl(this._dio);

  @override
  Future<String> summarizeText(String text) async {
    final url = '${AppEnv.cloudFunctionsBaseUrl}/api/summarize';

    // Dio AuthInterceptor automatically handles token injection.
    final response = await _dio.post(
      url,
      data: jsonEncode({'text': text}),
      options: Options(
        headers: {'Content-Type': 'application/json'},
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return response.data['summary'] as String;
    } else {
      throw FormatException('Unexpected response format: ${response.data}');
    }
  }
}
