import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/recording_entity.dart';

class RecordingHiveModel extends HiveObject {
  final String id;
  final String title;
  final String filePath;
  final int durationSeconds;
  final DateTime createdAt;
  String? transcriptionText;
  String? summaryText;
  final String ownerId;

  RecordingHiveModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.durationSeconds,
    required this.createdAt,
    this.transcriptionText,
    this.summaryText,
    required this.ownerId,
  });

  RecordingEntity toEntity() => RecordingEntity(
        id: id,
        title: title,
        filePath: filePath,
        durationSeconds: durationSeconds,
        createdAt: createdAt,
        transcriptionText: transcriptionText,
        summaryText: summaryText,
        ownerId: ownerId,
      );

  static RecordingHiveModel fromEntity(RecordingEntity entity) =>
      RecordingHiveModel(
        id: entity.id,
        title: entity.title,
        filePath: entity.filePath,
        durationSeconds: entity.durationSeconds,
        createdAt: entity.createdAt,
        transcriptionText: entity.transcriptionText,
        summaryText: entity.summaryText,
        ownerId: entity.ownerId,
      );
}

/// Manual Hive Adapter to avoid build_runner code generation
class RecordingHiveModelAdapter extends TypeAdapter<RecordingHiveModel> {
  @override
  final int typeId = 1;

  @override
  RecordingHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecordingHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      filePath: fields[2] as String,
      durationSeconds: fields[3] as int,
      createdAt: fields[4] as DateTime,
      transcriptionText: fields[5] as String?,
      summaryText: fields[6] as String?,
      ownerId: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecordingHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.transcriptionText)
      ..writeByte(6)
      ..write(obj.summaryText)
      ..writeByte(7)
      ..write(obj.ownerId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
