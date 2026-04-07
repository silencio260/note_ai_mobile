import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/recording_entity.dart';
import '../repositories/recording_repository.dart';

class GetRecordingsUseCase extends BaseUseCase<List<RecordingEntity>, String> {
  final RecordingRepository _repo;
  GetRecordingsUseCase(this._repo);

  @override
  Future<Either<Failure, List<RecordingEntity>>> call(String ownerId) {
    return _repo.getRecordings(ownerId);
  }
}

class SaveRecordingUseCase extends BaseUseCase<void, RecordingEntity> {
  final RecordingRepository _repo;
  SaveRecordingUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(RecordingEntity recording) {
    return _repo.saveRecording(recording);
  }
}

class DeleteRecordingUseCase extends BaseUseCase<void, String> {
  final RecordingRepository _repo;
  DeleteRecordingUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(String id) {
    return _repo.deleteRecording(id);
  }
}

class GetRecordingByIdUseCase extends BaseUseCase<RecordingEntity, String> {
  final RecordingRepository _repo;
  GetRecordingByIdUseCase(this._repo);

  @override
  Future<Either<Failure, RecordingEntity>> call(String id) {
    return _repo.getRecordingById(id);
  }
}
