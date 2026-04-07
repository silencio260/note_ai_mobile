import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/network/network_info.dart';
import 'data/datasources/local/summarization_local_datasource.dart';
import 'data/datasources/remote/summarization_remote_datasource.dart';
import 'data/models/summarization_hive_model.dart';
import 'data/repositories/summarization_repository_impl.dart';
import 'domain/repositories/summarization_repository.dart';
import 'domain/usecases/summarization_usecases.dart';
import 'presentation/bloc/summarization_bloc.dart';

Future<void> initSummarization(GetIt sl) async {
  // ── Box Registration ──────────────────────────────────────────────────────
  Hive.registerAdapter(SummarizationHiveModelAdapter());
  final summaryBox = await Hive.openBox<SummarizationHiveModel>('summarizations');

  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<SummarizationLocalDataSource>(
    () => SummarizationLocalDataSourceImpl(summaryBox),
  );
  sl.registerLazySingleton<SummarizationRemoteDataSource>(
    () => SummarizationRemoteDataSourceImpl(sl<Dio>()),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<SummarizationRepository>(
    () => SummarizationRepositoryImpl(
      sl<SummarizationLocalDataSource>(),
      sl<SummarizationRemoteDataSource>(),
      sl<NetworkInfo>(),
    ),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => SaveSummaryJobUseCase(sl<SummarizationRepository>()));
  sl.registerLazySingleton(() => GetPendingSummaryJobsUseCase(sl<SummarizationRepository>()));
  sl.registerLazySingleton(() => SummarizeTextRemoteUseCase(sl<SummarizationRepository>()));
  sl.registerLazySingleton(() => DeleteSummaryJobUseCase(sl<SummarizationRepository>()));

  // ── BLoC ──────────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => SummarizationBloc(
      saveJob: sl<SaveSummaryJobUseCase>(),
      getPendingJobs: sl<GetPendingSummaryJobsUseCase>(),
      summarizeText: sl<SummarizeTextRemoteUseCase>(),
      deleteJob: sl<DeleteSummaryJobUseCase>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
}
