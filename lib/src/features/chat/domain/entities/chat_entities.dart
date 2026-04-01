import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String role; // 'user' or 'assistant'
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, role, text, timestamp];
}

class ChatSession extends Equatable {
  final String id; // Matches the Recording ID this chat is attached to
  final List<ChatMessage> messages;
  final DateTime updatedAt;

  const ChatSession({
    required this.id,
    required this.messages,
    required this.updatedAt,
  });

  ChatSession copyWith({
    List<ChatMessage>? messages,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, messages, updatedAt];
}
