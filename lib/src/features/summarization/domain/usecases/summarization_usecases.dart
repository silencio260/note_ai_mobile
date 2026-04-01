import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/summarization_job_entity.dart';
import '../repositories/summarization_repository.dart';

class SaveSummaryJobUseCase extends BaseUseCase<void, SummarizationJobEntity> {
  final SummarizationRepository _repo;
  SaveSummaryJobUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(SummarizationJobEntity params) {
    return _repo.saveJob(params);
  }
}

class GetPendingSummaryJobsUseCase
    extends BaseUseCase<List<SummarizationJobEntity>, NoParams> {
  final SummarizationRepository _repo;
  GetPendingSummaryJobsUseCase(this._repo);

  @override
  Future<Either<Failure, List<SummarizationJobEntity>>> call(NoParams params) {
    return _repo.getPendingJobs();
  }
}

class SummarizeTextRemoteUseCase extends BaseUseCase<String, String> {
  final SummarizationRepository _repo;
  SummarizeTextRemoteUseCase(this._repo);

  @override
  Future<Either<Failure, String>> call(String params) {
    return _repo.summarizeText(params);
  }
}

class DeleteSummaryJobUseCase extends BaseUseCase<void, String> {
  final SummarizationRepository _repo;
  DeleteSummaryJobUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(String params) {
    return _repo.deleteJob(params);
  }
}
