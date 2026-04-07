import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/local/audio_recorder_datasource.dart';
import 'audio_record_event.dart';
import 'audio_record_state.dart';

class AudioRecordBloc extends Bloc<AudioRecordEvent, AudioRecordState> {
  final AudioRecorderDataSource _dataSource;
  StreamSubscription<AudioRecordingData>? _recordingSubscription;

  AudioRecordBloc({
    required AudioRecorderDataSource dataSource,
  })  : _dataSource = dataSource,
        super(const AudioRecordState()) {
    on<StartAudioRecording>(_onStart);
    on<StopAudioRecording>(_onStop);
    on<UpdateAudioDuration>(_onUpdateDuration);
  }

  Future<void> _onStart(StartAudioRecording event, Emitter<AudioRecordState> emit) async {
    emit(state.copyWith(status: AudioRecordStatus.initializing, errorMessage: null));
    try {
      final safeTitle = event.title.isEmpty ? 'Untitled Recording' : event.title;
      await _dataSource.startRecording(safeTitle);
      
      _recordingSubscription?.cancel();
      _recordingSubscription = _dataSource.recordingStream.listen((data) {
        add(UpdateAudioDuration(data.duration, data.amplitude));
      });

      emit(state.copyWith(
        status: AudioRecordStatus.recording,
        recordingTitle: safeTitle,
        duration: Duration.zero,
        amplitude: 0.0,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AudioRecordStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStop(StopAudioRecording event, Emitter<AudioRecordState> emit) async {
    emit(state.copyWith(status: AudioRecordStatus.stopping));
    try {
      final path = await _dataSource.stopRecording();
      _recordingSubscription?.cancel();
      
      emit(state.copyWith(
        status: AudioRecordStatus.success,
        savedFilePath: path,
      ));
      
      // Delay so listeners can pick up success state, then back to idle
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          emit(const AudioRecordState()); // Reset
        }
      });
      
    } catch (e) {
      emit(state.copyWith(
        status: AudioRecordStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdateDuration(UpdateAudioDuration event, Emitter<AudioRecordState> emit) {
    if (state.status == AudioRecordStatus.recording) {
      emit(state.copyWith(
        duration: event.duration,
        amplitude: event.amplitude,
      ));
    }
  }

  @override
  Future<void> close() {
    _recordingSubscription?.cancel();
    _dataSource.dispose();
    return super.close();
  }
}
