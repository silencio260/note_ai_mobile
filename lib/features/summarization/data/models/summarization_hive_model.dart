import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/summarization_job_entity.dart';

class SummarizationHiveModel extends HiveObject {
  final String id;
  final String textToSummarize;
  int statusCode; // 0=pending, 1=processing, 2=completed, 3=failed
  String? resultSummary;
  String? errorMessage;
  final DateTime createdAt;
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

/// Manual Hive Adapter for SummarizationHiveModel
class SummarizationHiveModelAdapter extends TypeAdapter<SummarizationHiveModel> {
  @override
  final int typeId = 2;

  @override
  SummarizationHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SummarizationHiveModel(
      id: fields[0] as String,
      textToSummarize: fields[1] as String,
      statusCode: fields[2] as int,
      resultSummary: fields[3] as String?,
      errorMessage: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SummarizationHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.textToSummarize)
      ..writeByte(2)
      ..write(obj.statusCode)
      ..writeByte(3)
      ..write(obj.resultSummary)
      ..writeByte(4)
      ..write(obj.errorMessage)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummarizationHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
