import 'package:dio/dio.dart';

import '../../../../../core/config/app_env.dart';

abstract class TranscriptionRemoteDataSource {
  Future<String> transcribeAudio(String filePath, String languageCode);
}

class TranscriptionRemoteDataSourceImpl
    implements TranscriptionRemoteDataSource {
  final Dio _dio;

  TranscriptionRemoteDataSourceImpl(this._dio);

  @override
  Future<String> transcribeAudio(String filePath, String languageCode) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'language': languageCode,
    });

    final url = '${AppEnv.cloudFunctionsBaseUrl}/api/transcribe';

    // The AuthInterceptor on Dio will automatically attach the Bearer token
    final response = await _dio.post(
      url,
      data: formData,
      options: Options(
        // Allow potentially longer timeouts for audio uploads/processing
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      // Assuming backend returns { "text": "..." }
      return response.data['text'] as String;
    } else {
      throw FormatException('Unexpected response format: ${response.data}');
    }
  }
}
