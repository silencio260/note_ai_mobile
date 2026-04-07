import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/chat_entities.dart';
import '../repositories/chat_repository.dart';

class GetChatSessionUseCase extends BaseUseCase<ChatSession?, String> {
  final ChatRepository _repo;
  GetChatSessionUseCase(this._repo);

  @override
  Future<Either<Failure, ChatSession?>> call(String recordingId) {
    return _repo.getSession(recordingId);
  }
}

class SaveChatSessionUseCase extends BaseUseCase<void, ChatSession> {
  final ChatRepository _repo;
  SaveChatSessionUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(ChatSession session) {
    return _repo.saveSession(session);
  }
}

class DeleteChatSessionUseCase extends BaseUseCase<void, String> {
  final ChatRepository _repo;
  DeleteChatSessionUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(String recordingId) {
    return _repo.deleteSession(recordingId);
  }
}

class SendChatMessageParams {
  final String recordingId;
  final String contextText;
  final String message;
  final List<ChatMessage> history;

  const SendChatMessageParams({
    required this.recordingId,
    required this.contextText,
    required this.message,
    required this.history,
  });
}

class SendChatMessageUseCase extends BaseUseCase<String, SendChatMessageParams> {
  final ChatRepository _repo;
  SendChatMessageUseCase(this._repo);

  @override
  Future<Either<Failure, String>> call(SendChatMessageParams params) {
    return _repo.sendMessage(
      recordingId: params.recordingId,
      contextText: params.contextText,
      message: params.message,
      history: params.history,
    );
  }
}
