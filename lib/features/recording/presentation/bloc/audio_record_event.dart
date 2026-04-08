import 'package:equatable/equatable.dart';

abstract class AudioRecordEvent extends Equatable {
  const AudioRecordEvent();

  @override
  List<Object?> get props => [];
}

class StartAudioRecording extends AudioRecordEvent {
  final String title;
  const StartAudioRecording(this.title);

  @override
  List<Object?> get props => [title];
}

class StopAudioRecording extends AudioRecordEvent {
  const StopAudioRecording();
}

class PauseAudioRecording extends AudioRecordEvent {
  const PauseAudioRecording();
}

class ResumeAudioRecording extends AudioRecordEvent {
  const ResumeAudioRecording();
}

class UpdateAudioDuration extends AudioRecordEvent {
  final Duration duration;
  final double amplitude;

  const UpdateAudioDuration(this.duration, this.amplitude);

  @override
  List<Object?> get props => [duration, amplitude];
}
