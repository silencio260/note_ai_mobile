import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/summarization_job_entity.dart';

abstract class SummarizationRepository {
  /// Save or update a job in the local queue
  Future<Either<Failure, void>> saveJob(SummarizationJobEntity job);

  /// Fetch all pending jobs (status == pending)
  Future<Either<Failure, List<SummarizationJobEntity>>> getPendingJobs();

  /// Call the remote backend to summarize the given text
  Future<Either<Failure, String>> summarizeText(String text);
  
  /// Delete a job (e.g. after completion or user cancellation)
  Future<Either<Failure, void>> deleteJob(String id);
}
