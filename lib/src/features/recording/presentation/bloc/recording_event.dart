part of 'recording_bloc.dart';

abstract class RecordingEvent extends Equatable {
  const RecordingEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecordingsRequested extends RecordingEvent {
  final String ownerId;

  const LoadRecordingsRequested(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}

class SaveRecordingRequested extends RecordingEvent {
  final RecordingEntity recording;

  const SaveRecordingRequested(this.recording);

  @override
  List<Object?> get props => [recording];
}

class DeleteRecordingRequested extends RecordingEvent {
  final String recordingId;
  final String ownerId; // Needed to refresh list

  const DeleteRecordingRequested({
    required this.recordingId,
    required this.ownerId,
  });

  @override
  List<Object?> get props => [recordingId, ownerId];
}

class UpdateRecordingTranscriptRequested extends RecordingEvent {
  final String recordingId;
  final String transcript;
  final String ownerId; // Needed to refresh list

  const UpdateRecordingTranscriptRequested({
    required this.recordingId,
    required this.transcript,
    required this.ownerId,
  });

  @override
  List<Object?> get props => [recordingId, transcript, ownerId];
}

class UpdateRecordingSummaryRequested extends RecordingEvent {
  final String recordingId;
  final String summary;
  final String ownerId;

  const UpdateRecordingSummaryRequested({
    required this.recordingId,
    required this.summary,
    required this.ownerId,
  });

  @override
  List<Object?> get props => [recordingId, summary, ownerId];
}
