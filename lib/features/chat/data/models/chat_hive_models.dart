import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/chat_entities.dart';

class ChatMessageHiveModel extends HiveObject {
  final String id;
  final String role;
  final String text;
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

class ChatSessionHiveModel extends HiveObject {
  final String id;
  final List<ChatMessageHiveModel> messages;
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
        messages: entity.messages
            .map((m) => ChatMessageHiveModel.fromEntity(m))
            .toList(),
        updatedAt: entity.updatedAt,
      );
}

/// Manual Hive Adapter for ChatMessageHiveModel
class ChatMessageHiveModelAdapter extends TypeAdapter<ChatMessageHiveModel> {
  @override
  final int typeId = 3;

  @override
  ChatMessageHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessageHiveModel(
      id: fields[0] as String,
      role: fields[1] as String,
      text: fields[2] as String,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessageHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.role)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Manual Hive Adapter for ChatSessionHiveModel
class ChatSessionHiveModelAdapter extends TypeAdapter<ChatSessionHiveModel> {
  @override
  final int typeId = 4;

  @override
  ChatSessionHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatSessionHiveModel(
      id: fields[0] as String,
      messages: (fields[1] as List).cast<ChatMessageHiveModel>(),
      updatedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChatSessionHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.messages)
      ..writeByte(2)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatSessionHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
