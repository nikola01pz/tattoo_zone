abstract class ChatEvent {}

class LoadConversations extends ChatEvent {
  final String userId;
  final bool isArtist;

  LoadConversations({
    required this.userId,
    required this.isArtist,
  });
}

class LoadMessages extends ChatEvent {
  final String conversationId;

  LoadMessages({
    required this.conversationId,
  });
}

class SendMessage extends ChatEvent {
  final String conversationId;
  final String senderId;
  final String text;

  SendMessage({
    required this.conversationId,
    required this.senderId,
    required this.text,
  });
}

class CreateConversation extends ChatEvent {
  final String artistId;
  final String clientId;
  final String artistName;
  final String clientName;

  CreateConversation({
    required this.artistId,
    required this.clientId,
    required this.artistName,
    required this.clientName,
  });
}