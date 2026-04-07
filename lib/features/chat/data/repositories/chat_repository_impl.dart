import 'package:dartz/dartz.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local/chat_local_datasource.dart';
import '../datasources/remote/chat_remote_datasource.dart';
import '../models/chat_hive_models.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource _localDataSource;
  final ChatRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ChatRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, ChatSession?>> getSession(String recordingId) async {
    try {
      final model = await _localDataSource.getSession(recordingId);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveSession(ChatSession session) async {
    try {
      final model = ChatSessionHiveModel.fromEntity(session);
      await _localDataSource.saveSession(model);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, String>> sendMessage({
    required String recordingId,
    required String contextText,
    required String message,
    required List<ChatMessage> history,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NoInternetConnectionFailure());
    }

    try {
      final reply = await _remoteDataSource.sendMessage(
        recordingId: recordingId,
        contextText: contextText,
        message: message,
        history: history,
      );
      return Right(reply);
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      if (failure is ServerFailure) {
        return Left(AIChatFailure(failure.message));
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String recordingId) async {
    try {
      await _localDataSource.deleteSession(recordingId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
