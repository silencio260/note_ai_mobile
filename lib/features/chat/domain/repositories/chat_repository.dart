import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/chat_entities.dart';

abstract class ChatRepository {
  /// Fetches a chat session (if exists) from local storage for a given recording ID
  Future<Either<Failure, ChatSession?>> getSession(String recordingId);

  /// Saves or updates a chat session locally
  Future<Either<Failure, void>> saveSession(ChatSession session);

  /// Sends a message string and the current conversation history to the backend
  /// Returns the AI's string response
  Future<Either<Failure, String>> sendMessage({
    required String recordingId,
    required String contextText, // The transcript/summary to base the chat on
    required String message,
    required List<ChatMessage> history,
  });

  /// Deletes a chat session
  Future<Either<Failure, void>> deleteSession(String recordingId);
}
