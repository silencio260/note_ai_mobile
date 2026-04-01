import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/recording_entity.dart';
import '../../domain/usecases/recording_usecases.dart';

part 'recording_event.dart';
part 'recording_state.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final GetRecordingsUseCase _getRecordings;
  final SaveRecordingUseCase _saveRecording;
  final DeleteRecordingUseCase _deleteRecording;
  final GetRecordingByIdUseCase _getRecordingById;

  RecordingBloc({
    required GetRecordingsUseCase getRecordings,
    required SaveRecordingUseCase saveRecording,
    required DeleteRecordingUseCase deleteRecording,
    required GetRecordingByIdUseCase getRecordingById,
  })  : _getRecordings = getRecordings,
        _saveRecording = saveRecording,
        _deleteRecording = deleteRecording,
        _getRecordingById = getRecordingById,
        super(const RecordingState()) {
    on<LoadRecordingsRequested>(_onLoadRecordings);
    on<SaveRecordingRequested>(_onSaveRecording);
    on<DeleteRecordingRequested>(_onDeleteRecording);
    on<UpdateRecordingTranscriptRequested>(_onUpdateTranscript);
    on<UpdateRecordingSummaryRequested>(_onUpdateSummary);
  }

  Future<void> _onLoadRecordings(
    LoadRecordingsRequested event,
    Emitter<RecordingState> emit,
  ) async {
    emit(state.copyWith(status: RecordingStatus.loading));
    final result = await _getRecordings(event.ownerId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: RecordingStatus.failure,
        errorMessage: failure.message,
      )),
      (recordings) => emit(state.copyWith(
        status: RecordingStatus.success,
        recordings: recordings,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onSaveRecording(
    SaveRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    // We don't necessarily emit loading here so we can do optimistic UI
    // if we want to, but for safety:
    emit(state.copyWith(status: RecordingStatus.loading));
    final result = await _saveRecording(event.recording);
    result.fold(
      (failure) => emit(state.copyWith(
        status: RecordingStatus.failure,
        errorMessage: failure.message,
      )),
      (_) {
        // Reload after save
        add(LoadRecordingsRequested(event.recording.ownerId));
      },
    );
  }

  Future<void> _onDeleteRecording(
    DeleteRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    emit(state.copyWith(status: RecordingStatus.loading));
    final result = await _deleteRecording(event.recordingId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: RecordingStatus.failure,
        errorMessage: failure.message,
      )),
      (_) {
        // Reload after delete
        add(LoadRecordingsRequested(event.ownerId));
      },
    );
  }

  Future<void> _onUpdateTranscript(
    UpdateRecordingTranscriptRequested event,
    Emitter<RecordingState> emit,
  ) async {
    // 1. Fetch current recording
    final getResult = await _getRecordingById(event.recordingId);
    await getResult.fold(
      (failure) async {
        emit(state.copyWith(
          status: RecordingStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (recording) async {
        // 2. Update with new transcript
        final updated = recording.copyWith(transcriptionText: event.transcript);
        final saveResult = await _saveRecording(updated);
        saveResult.fold(
          (failure) => emit(state.copyWith(
            status: RecordingStatus.failure,
            errorMessage: failure.message,
          )),
          (_) {
            add(LoadRecordingsRequested(event.ownerId));
          },
        );
      },
    );
  }

  Future<void> _onUpdateSummary(
    UpdateRecordingSummaryRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final getResult = await _getRecordingById(event.recordingId);
    await getResult.fold(
      (failure) async {
        emit(state.copyWith(
          status: RecordingStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (recording) async {
        final updated = recording.copyWith(summaryText: event.summary);
        final saveResult = await _saveRecording(updated);
        saveResult.fold(
          (failure) => emit(state.copyWith(
            status: RecordingStatus.failure,
            errorMessage: failure.message,
          )),
          (_) {
            add(LoadRecordingsRequested(event.ownerId));
          },
        );
      },
    );
  }
}
