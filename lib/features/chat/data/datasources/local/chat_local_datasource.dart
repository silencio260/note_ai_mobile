import 'package:hive_flutter/hive_flutter.dart';

import '../../models/chat_hive_models.dart';

abstract class ChatLocalDataSource {
  Future<ChatSessionHiveModel?> getSession(String recordingId);
  Future<void> saveSession(ChatSessionHiveModel session);
  Future<void> deleteSession(String recordingId);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final Box<ChatSessionHiveModel> _box;

  ChatLocalDataSourceImpl(this._box);

  @override
  Future<ChatSessionHiveModel?> getSession(String recordingId) async {
    return _box.get(recordingId);
  }

  @override
  Future<void> saveSession(ChatSessionHiveModel session) async {
    await _box.put(session.id, session);
  }

  @override
  Future<void> deleteSession(String recordingId) async {
    await _box.delete(recordingId);
  }
}
