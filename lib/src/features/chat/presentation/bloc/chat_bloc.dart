import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_entities.dart';
import '../../domain/usecases/chat_usecases.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatSessionUseCase _getSession;
  final SaveChatSessionUseCase _saveSession;
  final SendChatMessageUseCase _sendMessage;
  final DeleteChatSessionUseCase _deleteSession;
  
  final _uuid = const Uuid();

  ChatBloc({
    required GetChatSessionUseCase getSession,
    required SaveChatSessionUseCase saveSession,
    required SendChatMessageUseCase sendMessage,
    required DeleteChatSessionUseCase deleteSession,
  })  : _getSession = getSession,
        _saveSession = saveSession,
        _sendMessage = sendMessage,
        _deleteSession = deleteSession,
        super(const ChatState()) {
    on<LoadChatSessionRequested>(_onLoadSession);
    on<SendChatMessageRequested>(_onSendMessage);
    on<ClearChatSessionRequested>(_onClearSession);
  }

  Future<void> _onLoadSession(
    LoadChatSessionRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading, errorMessage: null));
    final result = await _getSession(event.recordingId);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: failure.message,
      )),
      (session) {
        if (session == null) {
          // Initialize empty session
          final newSession = ChatSession(
            id: event.recordingId,
            messages: const [],
            updatedAt: DateTime.now(),
          );
          emit(state.copyWith(
            status: ChatStatus.success,
            session: newSession,
          ));
        } else {
          emit(state.copyWith(
            status: ChatStatus.success,
            session: session,
          ));
        }
      },
    );
  }

  Future<void> _onSendMessage(
    SendChatMessageRequested event,
    Emitter<ChatState> emit,
  ) async {
    final currentSession = state.session ?? ChatSession(
      id: event.recordingId,
      messages: const [],
      updatedAt: DateTime.now(),
    );

    // 1. Append User Message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      role: 'user',
      text: event.text,
      timestamp: DateTime.now(),
    );

    final historyWithUser = List<ChatMessage>.from(currentSession.messages)..add(userMessage);

    final updatedSession = currentSession.copyWith(
      messages: historyWithUser,
      updatedAt: DateTime.now(),
    );

    // Optimistically update UI
    emit(state.copyWith(
      session: updatedSession,
      isSending: true,
      errorMessage: null,
    ));

    // Save to Hive
    await _saveSession(updatedSession);

    // 2. Call AI Backend
    final result = await _sendMessage(SendChatMessageParams(
      recordingId: event.recordingId,
      contextText: event.contextText,
      message: event.text,
      history: currentSession.messages, // Only send history BEFORE current user message, backend usually prefers it this way, or you can send historyWithUser. 
      // Actually backend needs full history if we expect it to see the user's latest message in history. 
      // Wait, our API spec sends `message` separately. So history should NOT include the current message.
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isSending: false,
          errorMessage: failure.message,
        ));
      },
      (replyText) async {
        // Append Assistant Message
        final assistantMsg = ChatMessage(
          id: _uuid.v4(),
          role: 'assistant',
          text: replyText,
          timestamp: DateTime.now(),
        );
        
        final finalHistory = List<ChatMessage>.from(historyWithUser)..add(assistantMsg);
        
        final finalSession = updatedSession.copyWith(
          messages: finalHistory,
          updatedAt: DateTime.now(),
        );

        await _saveSession(finalSession);

        emit(state.copyWith(
          isSending: false,
          session: finalSession,
        ));
      },
    );
  }

  Future<void> _onClearSession(
    ClearChatSessionRequested event,
    Emitter<ChatState> emit,
  ) async {
    await _deleteSession(event.recordingId);
    emit(state.copyWith(
      session: ChatSession(
        id: event.recordingId,
        messages: const [],
        updatedAt: DateTime.now(),
      ),
    ));
  }
}
