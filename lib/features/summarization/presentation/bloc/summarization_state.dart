part of 'summarization_bloc.dart';

class SummarizationState extends Equatable {
  final List<SummarizationJobEntity> activeJobs;
  final String? lastError;

  const SummarizationState({
    this.activeJobs = const [],
    this.lastError,
  });

  SummarizationState copyWith({
    List<SummarizationJobEntity>? activeJobs,
    String? lastError,
  }) {
    return SummarizationState(
      activeJobs: activeJobs ?? this.activeJobs,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  List<Object?> get props => [activeJobs, lastError];

  /// Find job status for a specific recording
  SummarizationStatus? statusFor(String recordingId) {
    try {
      final job = activeJobs.firstWhere((j) => j.id == recordingId);
      return job.status;
    } catch (_) {
      return null;
    }
  }
}
