import 'package:dartz/dartz.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/recording_entity.dart';
import '../../domain/repositories/recording_repository.dart';
import '../datasources/local/recording_local_datasource.dart';
import '../models/recording_hive_model.dart';

class RecordingRepositoryImpl implements RecordingRepository {
  final RecordingLocalDataSource _localDataSource;

  RecordingRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, void>> saveRecording(RecordingEntity recording) async {
    try {
      final model = RecordingHiveModel.fromEntity(recording);
      await _localDataSource.saveRecording(model);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<RecordingEntity>>> getRecordings(
      String ownerId) async {
    try {
      final models = await _localDataSource.getRecordings(ownerId);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, RecordingEntity>> getRecordingById(String id) async {
    try {
      final model = await _localDataSource.getRecordingById(id);
      if (model != null) {
        return Right(model.toEntity());
      } else {
        return const Left(NotFoundFailure('Recording not found'));
      }
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecording(String id) async {
    try {
      await _localDataSource.deleteRecording(id);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
