import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final String artistId;
  final String clientId;
  final String artistName;
  final String clientName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadArtist;
  final int unreadClient;

  ConversationModel({
    required this.id,
    required this.artistId,
    required this.clientId,
    required this.artistName,
    required this.clientName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadArtist,
    required this.unreadClient,
  });

  factory ConversationModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    final rawLastMessageTime = data['lastMessageTime'];

    return ConversationModel(
      id: id,
      artistId: data['artistId'] ?? '',
      clientId: data['clientId'] ?? '',
      artistName: data['artistName'] ?? '',
      clientName: data['clientName'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: rawLastMessageTime is Timestamp
          ? rawLastMessageTime.toDate()
          : DateTime.now(),
      unreadArtist: data['unreadArtist'] ?? 0,
      unreadClient: data['unreadClient'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'artistId': artistId,
      'clientId': clientId,
      'artistName': artistName,
      'clientName': clientName,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadArtist': unreadArtist,
      'unreadClient': unreadClient,
    };
  }
}