import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tattoo_zona/features/chat/repository/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(ChatInitial()) {
    on<LoadConversations>((event, emit) async {
      emit(ChatLoading());
      try {
        final stream = event.isArtist
            ? _chatRepository.getArtistConversations(event.userId)
            : _chatRepository.getClientConversations(event.userId);

        await emit.forEach(
          stream,
          onData: (conversations) =>
              ConversationsLoaded(conversations: conversations),
        );
      } catch (e) {
        emit(ChatError(message: e.toString()));
      }
    });

    on<LoadMessages>((event, emit) async {
      emit(ChatLoading());
      try {
        final stream = _chatRepository.getMessages(event.conversationId);

        await emit.forEach(
          stream,
          onData: (messages) => MessagesLoaded(messages: messages),
        );
      } catch (e) {
        emit(ChatError(message: e.toString()));
      }
    });

    on<SendMessage>((event, emit) async {
      try {
        await _chatRepository.sendMessage(
          conversationId: event.conversationId,
          senderId: event.senderId,
          text: event.text,
        );
      } catch (e) {
        emit(ChatError(message: e.toString()));
      }
    });

    on<CreateConversation>((event, emit) async {
      emit(ChatLoading());
      try {
        final id = await _chatRepository.createConversation(
          artistId: event.artistId,
          clientId: event.clientId,
          artistName: event.artistName,
          clientName: event.clientName,
        );

        emit(ConversationCreated(conversationId: id));
      } catch (e) {
        emit(ChatError(message: e.toString()));
      }
    });
  }
}