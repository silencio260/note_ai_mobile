import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/network_info.dart';
import '../../domain/entities/summarization_job_entity.dart';
import '../../domain/usecases/summarization_usecases.dart';

import '../../../../core/usecase/base_usecase.dart';

part 'summarization_event.dart';
part 'summarization_state.dart';

class SummarizationBloc extends Bloc<SummarizationEvent, SummarizationState> {
  final SaveSummaryJobUseCase _saveJob;
  final GetPendingSummaryJobsUseCase _getPendingJobs;
  final SummarizeTextRemoteUseCase _summarizeText;
  final DeleteSummaryJobUseCase _deleteJob;
  final NetworkInfo _networkInfo;
  
  StreamSubscription? _networkSub;

  SummarizationBloc({
    required SaveSummaryJobUseCase saveJob,
    required GetPendingSummaryJobsUseCase getPendingJobs,
    required SummarizeTextRemoteUseCase summarizeText,
    required DeleteSummaryJobUseCase deleteJob,
    required NetworkInfo networkInfo,
  })  : _saveJob = saveJob,
        _getPendingJobs = getPendingJobs,
        _summarizeText = summarizeText,
        _deleteJob = deleteJob,
        _networkInfo = networkInfo,
        super(const SummarizationState()) {
    on<ProcessPendingJobsRequested>(_onProcessPending);
    on<SummarizeTextRequested>(_onSummarizeText);
    on<CancelSummaryJobRequested>(_onCancelJob);

    // Listen to network changes and auto-resume pending tasks if online
    if (_networkInfo is NetworkInfoImpl) {
      final connectivity = _networkInfo.connectivity;
      _networkSub = connectivity.onConnectivityChanged.listen((results) {
        if (!results.contains(ConnectivityResult.none)) {
          add(const ProcessPendingJobsRequested());
        }
      });
    }
  }

  Future<void> _onProcessPending(
    ProcessPendingJobsRequested event,
    Emitter<SummarizationState> emit,
  ) async {
    final pendingResult = await _getPendingJobs(const NoParams());
    pendingResult.fold(
      (l) => null,
      (jobs) async {
        for (final job in jobs) {
          // Re-emit intention to summarize
          add(SummarizeTextRequested(
            recordingId: job.id, 
            text: job.textToSummarize,
          ));
        }
      },
    );
  }

  Future<void> _onSummarizeText(
    SummarizeTextRequested event,
    Emitter<SummarizationState> emit,
  ) async {
    // 1. Mark as processing in state
    final job = SummarizationJobEntity(
      id: event.recordingId,
      textToSummarize: event.text,
      status: SummarizationStatus.processing,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Add to active jobs list
    final updatedList = List<SummarizationJobEntity>.from(state.activeJobs)
      ..removeWhere((j) => j.id == job.id)
      ..add(job);
    emit(state.copyWith(activeJobs: updatedList));

    // Save to local offline queue in case we crash
    await _saveJob(job);

    // 2. Call Remote API
    final result = await _summarizeText(event.text);
    result.fold(
      (failure) async {
        // Failed -> move to Pending or Failed depending on error type
        final failedJob = job.copyWith(
          status: SummarizationStatus.failed, // or pending if it's a network disconnect
          errorMessage: failure.message,
          updatedAt: DateTime.now(),
        );
        await _saveJob(failedJob);
        
        final list = List<SummarizationJobEntity>.from(state.activeJobs)
          ..removeWhere((j) => j.id == job.id)
          ..add(failedJob);
        emit(state.copyWith(activeJobs: list, lastError: failure.message));
      },
      (summary) async {
        // Success -> move to Complete, remove from queue
        // In reality, we might emit something that the RecordingBloc picks up to save it permanently,
        // or we just delete it from the queue because our UI will catch the Success status.
        final completeJob = job.copyWith(
          status: SummarizationStatus.completed,
          resultSummary: summary,
          updatedAt: DateTime.now(),
        );
        await _deleteJob(job.id); // Job done, remove from queue
        
        final list = List<SummarizationJobEntity>.from(state.activeJobs)
          ..removeWhere((j) => j.id == job.id)
          ..add(completeJob);
        emit(state.copyWith(activeJobs: list, lastError: null));
      },
    );
  }

  Future<void> _onCancelJob(
    CancelSummaryJobRequested event,
    Emitter<SummarizationState> emit,
  ) async {
    await _deleteJob(event.recordingId);
    final list = List<SummarizationJobEntity>.from(state.activeJobs)
      ..removeWhere((j) => j.id == event.recordingId);
    emit(state.copyWith(activeJobs: list));
  }

  @override
  Future<void> close() {
    _networkSub?.cancel();
    return super.close();
  }
}
