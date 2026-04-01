part of 'summarization_bloc.dart';

abstract class SummarizationEvent extends Equatable {
  const SummarizationEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the network connection restores or app launches to 
/// process any jobs stuck in 'pending' status.
class ProcessPendingJobsRequested extends SummarizationEvent {
  const ProcessPendingJobsRequested();
}

/// Dispatched when the user clicks 'Summarize' on a transcript.
class SummarizeTextRequested extends SummarizationEvent {
  final String recordingId;
  final String text;

  const SummarizeTextRequested({
    required this.recordingId,
    required this.text,
  });

  @override
  List<Object?> get props => [recordingId, text];
}

class CancelSummaryJobRequested extends SummarizationEvent {
  final String recordingId;
  
  const CancelSummaryJobRequested(this.recordingId);

  @override
  List<Object?> get props => [recordingId];
}
