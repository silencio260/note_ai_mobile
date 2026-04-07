part of 'recording_bloc.dart';

enum RecordingStatus { initial, loading, success, failure }

class RecordingState extends Equatable {
  final RecordingStatus status;
  final List<RecordingEntity> recordings;
  final String? errorMessage;

  const RecordingState({
    this.status = RecordingStatus.initial,
    this.recordings = const [],
    this.errorMessage,
  });

  RecordingState copyWith({
    RecordingStatus? status,
    List<RecordingEntity>? recordings,
    String? errorMessage,
  }) {
    return RecordingState(
      status: status ?? this.status,
      recordings: recordings ?? this.recordings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, recordings, errorMessage];
}
