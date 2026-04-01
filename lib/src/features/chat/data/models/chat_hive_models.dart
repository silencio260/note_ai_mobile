import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/chat_entities.dart';

part 'chat_hive_models.g.dart';

@HiveType(typeId: 3)
class ChatMessageHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String role;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final DateTime timestamp;

  ChatMessageHiveModel({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
  });

  ChatMessage toEntity() => ChatMessage(
        id: id,
        role: role,
        text: text,
        timestamp: timestamp,
      );

  static ChatMessageHiveModel fromEntity(ChatMessage entity) =>
      ChatMessageHiveModel(
        id: entity.id,
        role: entity.role,
        text: entity.text,
        timestamp: entity.timestamp,
      );
}

@HiveType(typeId: 4)
class ChatSessionHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<ChatMessageHiveModel> messages;

  @HiveField(2)
  final DateTime updatedAt;

  ChatSessionHiveModel({
    required this.id,
    required this.messages,
    required this.updatedAt,
  });

  ChatSession toEntity() => ChatSession(
        id: id,
        messages: messages.map((m) => m.toEntity()).toList(),
        updatedAt: updatedAt,
      );

  static ChatSessionHiveModel fromEntity(ChatSession entity) =>
      ChatSessionHiveModel(
        id: entity.id,
        messages: entity.messages.map((m) => ChatMessageHiveModel.fromEntity(m)).toList(),
        updatedAt: entity.updatedAt,
      );
}
