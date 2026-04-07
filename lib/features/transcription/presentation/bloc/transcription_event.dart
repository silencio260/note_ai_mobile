part of 'transcription_bloc.dart';

abstract class TranscriptionEvent extends Equatable {
  const TranscriptionEvent();

  @override
  List<Object?> get props => [];
}

class TranscriptionStarted extends TranscriptionEvent {
  final String recordingId; // Optional: to know which recording is processing
  final String filePath;
  final String languageCode;

  const TranscriptionStarted({
    required this.recordingId,
    required this.filePath,
    required this.languageCode,
  });

  @override
  List<Object?> get props => [recordingId, filePath, languageCode];
}
