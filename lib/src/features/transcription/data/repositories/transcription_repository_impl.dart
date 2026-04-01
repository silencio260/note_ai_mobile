import 'package:dartz/dartz.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/transcription_repository.dart';
import '../datasources/remote/transcription_remote_datasource.dart';

class TranscriptionRepositoryImpl implements TranscriptionRepository {
  final TranscriptionRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  TranscriptionRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, String>> transcribeAudio({
    required String filePath,
    required String languageCode,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NoInternetConnectionFailure());
    }

    try {
      final result = await _remoteDataSource.transcribeAudio(
        filePath,
        languageCode,
      );
      return Right(result);
    } catch (e) {
      // Convert specific Dio or runtime errors to domain failures
      final failure = ErrorHandler.handle(e);
      // Give it a more relevant error type if it's a generic ServerFailure
      if (failure is ServerFailure) {
        return Left(AITranscriptionFailure(failure.message));
      }
      return Left(failure);
    }
  }
}
