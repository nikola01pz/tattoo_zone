import 'package:tattoo_zona/features/shared/models/conversation_model.dart';
import 'package:tattoo_zona/features/shared/models/message_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<ConversationModel> conversations;

  ConversationsLoaded({
    required this.conversations,
  });
}

class MessagesLoaded extends ChatState {
  final List<MessageModel> messages;

  MessagesLoaded({
    required this.messages,
  });
}

class ChatError extends ChatState {
  final String message;

  ChatError({
    required this.message,
  });
}

class ConversationCreated extends ChatState {
  final String conversationId;

  ConversationCreated({
    required this.conversationId,
  });
}