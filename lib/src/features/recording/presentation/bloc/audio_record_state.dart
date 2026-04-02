import 'package:equatable/equatable.dart';

enum AudioRecordStatus { idle, initializing, recording, stopping, success, failure }

class AudioRecordState extends Equatable {
  final AudioRecordStatus status;
  final Duration duration;
  final double amplitude;
  final String? savedFilePath;
  final String? errorMessage;
  final String? recordingTitle;

  const AudioRecordState({
    this.status = AudioRecordStatus.idle,
    this.duration = Duration.zero,
    this.amplitude = 0.0,
    this.savedFilePath,
    this.errorMessage,
    this.recordingTitle,
  });

  AudioRecordState copyWith({
    AudioRecordStatus? status,
    Duration? duration,
    double? amplitude,
    String? savedFilePath,
    String? errorMessage,
    String? recordingTitle,
  }) {
    return AudioRecordState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      amplitude: amplitude ?? this.amplitude,
      savedFilePath: savedFilePath ?? this.savedFilePath,
      errorMessage: errorMessage ?? this.errorMessage,
      recordingTitle: recordingTitle ?? this.recordingTitle,
    );
  }

  @override
  List<Object?> get props => [status, duration, amplitude, savedFilePath, errorMessage, recordingTitle];
}
