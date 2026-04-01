import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/recording_entity.dart';

part 'recording_hive_model.g.dart';

@HiveType(typeId: 1)
class RecordingHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String filePath;

  @HiveField(3)
  final int durationSeconds;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  String? transcriptionText;

  @HiveField(6)
  String? summaryText;

  @HiveField(7)
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
