import 'package:hive_flutter/hive_flutter.dart';

import '../../models/summarization_hive_model.dart';

abstract class SummarizationLocalDataSource {
  Future<void> saveJob(SummarizationHiveModel job);
  Future<List<SummarizationHiveModel>> getPendingJobs();
  Future<void> deleteJob(String id);
}

class SummarizationLocalDataSourceImpl implements SummarizationLocalDataSource {
  final Box<SummarizationHiveModel> _box;

  SummarizationLocalDataSourceImpl(this._box);

  @override
  Future<void> saveJob(SummarizationHiveModel job) async {
    await _box.put(job.id, job);
  }

  @override
  Future<List<SummarizationHiveModel>> getPendingJobs() async {
    return _box.values
        // statusCode 0 == pending
        .where((job) => job.statusCode == 0)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<void> deleteJob(String id) async {
    await _box.delete(id);
  }
}
