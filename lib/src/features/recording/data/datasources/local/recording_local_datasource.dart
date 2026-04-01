import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';

import '../../models/recording_hive_model.dart';

abstract class RecordingLocalDataSource {
  Future<void> saveRecording(RecordingHiveModel model);
  Future<List<RecordingHiveModel>> getRecordings(String ownerId);
  Future<RecordingHiveModel?> getRecordingById(String id);
  Future<void> deleteRecording(String id);
}

class RecordingLocalDataSourceImpl implements RecordingLocalDataSource {
  final Box<RecordingHiveModel> _box;

  RecordingLocalDataSourceImpl(this._box);

  @override
  Future<void> saveRecording(RecordingHiveModel model) async {
    await _box.put(model.id, model);
  }

  @override
  Future<List<RecordingHiveModel>> getRecordings(String ownerId) async {
    // Filter by ownerId down here to support multiple accounts/guests on same device
    return _box.values
        .where((record) => record.ownerId == ownerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<RecordingHiveModel?> getRecordingById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> deleteRecording(String id) async {
    final record = _box.get(id);
    if (record != null) {
      final file = File(record.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      await _box.delete(id);
    }
  }
}
