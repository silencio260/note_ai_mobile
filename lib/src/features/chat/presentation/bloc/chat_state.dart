part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  final ChatStatus status;
  final ChatSession? session;
  final String? errorMessage;
  final bool isSending; // specifically true when waiting for AI reply

  const ChatState({
    this.status = ChatStatus.initial,
    this.session,
    this.errorMessage,
    this.isSending = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    ChatSession? session,
    String? errorMessage,
    bool? isSending,
  }) {
    return ChatState(
      status: status ?? this.status,
      // If we pass a specific null (to clear session), Dart copyWith pattern is tricky. 
      // But we always keep the session unless explicitly cleared.
      session: session ?? this.session,
      errorMessage: errorMessage ?? this.errorMessage,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [status, session, errorMessage, isSending];
}
