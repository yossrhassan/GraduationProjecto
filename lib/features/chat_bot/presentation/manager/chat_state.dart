part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoading(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatError extends ChatState {
  final List<ChatMessage> messages;
  final String error;

  const ChatError(this.messages, this.error);

  @override
  List<Object> get props => [messages, error];
}
