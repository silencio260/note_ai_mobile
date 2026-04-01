import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/summarization_job_entity.dart';

part 'summarization_hive_model.g.dart';

@HiveType(typeId: 2)
class SummarizationHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String textToSummarize;

  @HiveField(2)
  int statusCode; // 0=pending, 1=processing, 2=completed, 3=failed

  @HiveField(3)
  String? resultSummary;

  @HiveField(4)
  String? errorMessage;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  SummarizationHiveModel({
    required this.id,
    required this.textToSummarize,
    required this.statusCode,
    this.resultSummary,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  SummarizationJobEntity toEntity() {
    return SummarizationJobEntity(
      id: id,
      textToSummarize: textToSummarize,
      status: SummarizationStatus.values[statusCode],
      resultSummary: resultSummary,
      errorMessage: errorMessage,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static SummarizationHiveModel fromEntity(SummarizationJobEntity entity) {
    return SummarizationHiveModel(
      id: entity.id,
      textToSummarize: entity.textToSummarize,
      statusCode: entity.status.index,
      resultSummary: entity.resultSummary,
      errorMessage: entity.errorMessage,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
