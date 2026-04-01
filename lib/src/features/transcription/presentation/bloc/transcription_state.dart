part of 'transcription_bloc.dart';

enum TranscriptionStatus { initial, loading, success, failure }

class TranscriptionState extends Equatable {
  final TranscriptionStatus status;
  final String? activeRecordingId;
  final String? resultText;
  final String? errorMessage;

  const TranscriptionState({
    this.status = TranscriptionStatus.initial,
    this.activeRecordingId,
    this.resultText,
    this.errorMessage,
  });

  TranscriptionState copyWith({
    TranscriptionStatus? status,
    String? activeRecordingId,
    String? resultText,
    String? errorMessage,
  }) {
    return TranscriptionState(
      status: status ?? this.status,
      activeRecordingId: activeRecordingId ?? this.activeRecordingId,
      resultText: resultText ?? this.resultText,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeRecordingId,
        resultText,
        errorMessage,
      ];
}
