import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/recording_entity.dart';

abstract class RecordingRepository {
  /// Save a new or updated recording to local storage
  Future<Either<Failure, void>> saveRecording(RecordingEntity recording);

  /// Fetch all recordings belonging to the current user (ownerId)
  Future<Either<Failure, List<RecordingEntity>>> getRecordings(String ownerId);

  /// Fetch a specific recording by its ID
  Future<Either<Failure, RecordingEntity>> getRecordingById(String id);

  /// Delete a recording and its associated audio file
  Future<Either<Failure, void>> deleteRecording(String id);
}
