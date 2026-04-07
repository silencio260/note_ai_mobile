import 'package:dartz/dartz.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/summarization_job_entity.dart';
import '../../domain/repositories/summarization_repository.dart';
import '../datasources/local/summarization_local_datasource.dart';
import '../datasources/remote/summarization_remote_datasource.dart';
import '../models/summarization_hive_model.dart';

class SummarizationRepositoryImpl implements SummarizationRepository {
  final SummarizationLocalDataSource _localDataSource;
  final SummarizationRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  SummarizationRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, void>> saveJob(SummarizationJobEntity job) async {
    try {
      final model = SummarizationHiveModel.fromEntity(job);
      await _localDataSource.saveJob(model);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<SummarizationJobEntity>>> getPendingJobs() async {
    try {
      final models = await _localDataSource.getPendingJobs();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, String>> summarizeText(String text) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NoInternetConnectionFailure());
    }
    try {
      final result = await _remoteDataSource.summarizeText(text);
      return Right(result);
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      if (failure is ServerFailure) {
        return Left(AISummaryFailure(failure.message));
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> deleteJob(String id) async {
    try {
      await _localDataSource.deleteJob(id);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
