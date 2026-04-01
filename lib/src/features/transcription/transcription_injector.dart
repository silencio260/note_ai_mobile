import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/network/network_info.dart';
import 'data/datasources/remote/transcription_remote_datasource.dart';
import 'data/repositories/transcription_repository_impl.dart';
import 'domain/repositories/transcription_repository.dart';
import 'domain/usecases/transcribe_audio_usecase.dart';
import 'presentation/bloc/transcription_bloc.dart';

void initTranscription(GetIt sl) {
  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<TranscriptionRemoteDataSource>(
    () => TranscriptionRemoteDataSourceImpl(sl<Dio>()),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<TranscriptionRepository>(
    () => TranscriptionRepositoryImpl(
      sl<TranscriptionRemoteDataSource>(),
      sl<NetworkInfo>(),
    ),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => TranscribeAudioUseCase(sl<TranscriptionRepository>()),
  );

  // ── BLoC ──────────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => TranscriptionBloc(transcribeAudio: sl<TranscribeAudioUseCase>()),
  );
}
