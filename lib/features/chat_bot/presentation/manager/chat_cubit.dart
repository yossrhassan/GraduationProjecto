import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/chat_message.dart';
import '../../data/repos/chat_repo.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this.chatRepo) : super(ChatInitial()) {
    _addWelcomeMessage();
  }

  final ChatRepo chatRepo;
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      text:
          "Hello! I'm your sports facilities assistant. Ask me about sports facilities in any area!",
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.insert(0, welcomeMessage);
    emit(ChatLoaded(_messages));
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.insert(0, userMessage);
    emit(ChatLoading(_messages));

    // Send message to API
    final result = await chatRepo.sendMessage(message);

    result.fold(
      (error) {
        // Add error message
        final errorMessage = ChatMessage(
          text:
              "Sorry, I'm having trouble connecting. Please make sure the server is running and try again.",
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.insert(0, errorMessage);
        emit(ChatError(_messages, error));
      },
      (response) {
        // Add bot response
        final botMessage = ChatMessage(
          text: response.data.response,
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.insert(0, botMessage);
        emit(ChatLoaded(_messages));
      },
    );
  }

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
  }
}
