import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/network/network_info.dart';
import 'data/datasources/local/chat_local_datasource.dart';
import 'data/datasources/remote/chat_remote_datasource.dart';
import 'data/models/chat_hive_models.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/usecases/chat_usecases.dart';
import 'presentation/bloc/chat_bloc.dart';

Future<void> initChat(GetIt sl) async {
  // ── Box Registration ──────────────────────────────────────────────────────
  Hive.registerAdapter(ChatMessageHiveModelAdapter());
  Hive.registerAdapter(ChatSessionHiveModelAdapter());
  final chatBox = await Hive.openBox<ChatSessionHiveModel>('chat_sessions');

  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(chatBox),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl<Dio>()),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      sl<ChatLocalDataSource>(),
      sl<ChatRemoteDataSource>(),
      sl<NetworkInfo>(),
    ),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetChatSessionUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => SaveChatSessionUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => SendChatMessageUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => DeleteChatSessionUseCase(sl<ChatRepository>()));

  // ── BLoC ──────────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => ChatBloc(
      getSession: sl<GetChatSessionUseCase>(),
      saveSession: sl<SaveChatSessionUseCase>(),
      sendMessage: sl<SendChatMessageUseCase>(),
      deleteSession: sl<DeleteChatSessionUseCase>(),
    ),
  );
}
