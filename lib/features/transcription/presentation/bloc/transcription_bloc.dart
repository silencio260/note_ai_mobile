import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/transcribe_audio_usecase.dart';

part 'transcription_event.dart';
part 'transcription_state.dart';

class TranscriptionBloc extends Bloc<TranscriptionEvent, TranscriptionState> {
  final TranscribeAudioUseCase _transcribeAudio;

  TranscriptionBloc({
    required TranscribeAudioUseCase transcribeAudio,
  })  : _transcribeAudio = transcribeAudio,
        super(const TranscriptionState()) {
    on<TranscriptionStarted>(_onTranscriptionStarted);
  }

  Future<void> _onTranscriptionStarted(
    TranscriptionStarted event,
    Emitter<TranscriptionState> emit,
  ) async {
    // Only process one transcription at a time 
    // In a real app we might allow multiples or use a queue
    emit(state.copyWith(
      status: TranscriptionStatus.loading,
      activeRecordingId: event.recordingId,
      errorMessage: null,
      resultText: null,
    ));

    final result = await _transcribeAudio(TranscribeAudioParams(
      filePath: event.filePath,
      languageCode: event.languageCode,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: TranscriptionStatus.failure,
        errorMessage: failure.message,
      )),
      (text) => emit(state.copyWith(
        status: TranscriptionStatus.success,
        resultText: text,
      )),
    );
  }
}
