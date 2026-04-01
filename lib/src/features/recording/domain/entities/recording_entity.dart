import 'package:equatable/equatable.dart';

class RecordingEntity extends Equatable {
  final String id;
  final String title;
  final String filePath;
  final int durationSeconds;
  final DateTime createdAt;
  final String? transcriptionText;
  final String? summaryText;
  final String ownerId;

  const RecordingEntity({
    required this.id,
    required this.title,
    required this.filePath,
    required this.durationSeconds,
    required this.createdAt,
    this.transcriptionText,
    this.summaryText,
    required this.ownerId,
  });

  RecordingEntity copyWith({
    String? id,
    String? title,
    String? filePath,
    int? durationSeconds,
    DateTime? createdAt,
    String? transcriptionText,
    String? summaryText,
    String? ownerId,
  }) {
    return RecordingEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
      transcriptionText: transcriptionText ?? this.transcriptionText,
      summaryText: summaryText ?? this.summaryText,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        filePath,
        durationSeconds,
        createdAt,
        transcriptionText,
        summaryText,
        ownerId,
      ];
}
