part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatSessionRequested extends ChatEvent {
  final String recordingId;

  const LoadChatSessionRequested(this.recordingId);

  @override
  List<Object?> get props => [recordingId];
}

class SendChatMessageRequested extends ChatEvent {
  final String recordingId;
  final String contextText;
  final String text;

  const SendChatMessageRequested({
    required this.recordingId,
    required this.contextText,
    required this.text,
  });

  @override
  List<Object?> get props => [recordingId, contextText, text];
}

class ClearChatSessionRequested extends ChatEvent {
  final String recordingId;

  const ClearChatSessionRequested(this.recordingId);

  @override
  List<Object?> get props => [recordingId];
}
