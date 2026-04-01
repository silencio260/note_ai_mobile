import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/datasources/local/recording_local_datasource.dart';
import 'data/models/recording_hive_model.dart';
import 'data/repositories/recording_repository_impl.dart';
import 'domain/repositories/recording_repository.dart';
import 'domain/usecases/recording_usecases.dart';
import 'presentation/bloc/recording_bloc.dart';

Future<void> initRecording(GetIt sl) async {
  // ── Box Registration ──────────────────────────────────────────────────────
  Hive.registerAdapter(RecordingHiveModelAdapter());
  final recordingBox = await Hive.openBox<RecordingHiveModel>('recordings');

  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<RecordingLocalDataSource>(
    () => RecordingLocalDataSourceImpl(recordingBox),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<RecordingRepository>(
    () => RecordingRepositoryImpl(sl<RecordingLocalDataSource>()),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetRecordingsUseCase(sl<RecordingRepository>()));
  sl.registerLazySingleton(() => SaveRecordingUseCase(sl<RecordingRepository>()));
  sl.registerLazySingleton(() => DeleteRecordingUseCase(sl<RecordingRepository>()));
  sl.registerLazySingleton(() => GetRecordingByIdUseCase(sl<RecordingRepository>()));

  // ── BLoC ──────────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => RecordingBloc(
      getRecordings: sl<GetRecordingsUseCase>(),
      saveRecording: sl<SaveRecordingUseCase>(),
      deleteRecording: sl<DeleteRecordingUseCase>(),
      getRecordingById: sl<GetRecordingByIdUseCase>(),
    ),
  );
}
