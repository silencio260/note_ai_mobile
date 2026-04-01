import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../../../core/config/app_env.dart';
import '../../../domain/entities/chat_entities.dart';

abstract class ChatRemoteDataSource {
  Future<String> sendMessage({
    required String recordingId,
    required String contextText,
    required String message,
    required List<ChatMessage> history,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio;

  ChatRemoteDataSourceImpl(this._dio);

  @override
  Future<String> sendMessage({
    required String recordingId,
    required String contextText,
    required String message,
    required List<ChatMessage> history,
  }) async {
    final url = '${AppEnv.cloudFunctionsBaseUrl}/api/chat';

    final requestData = {
      'recordingId': recordingId,
      'context': contextText,
      'message': message,
      'history': history.map((m) => {
        'role': m.role,
        'content': m.text,
      }).toList(),
    };

    final response = await _dio.post(
      url,
      data: jsonEncode(requestData),
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return response.data['reply'] as String;
    } else {
      throw FormatException('Unexpected response format: ${response.data}');
    }
  }
}
