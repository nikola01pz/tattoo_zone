import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tattoo_zona/features/shared/models/conversation_model.dart';
import 'package:tattoo_zona/features/shared/models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ConversationModel>> getArtistConversations(String artistId) {
    return _firestore
        .collection('conversations')
        .where('artistId', isEqualTo: artistId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ConversationModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<ConversationModel>> getClientConversations(String clientId) {
    return _firestore
        .collection('conversations')
        .where('clientId', isEqualTo: clientId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ConversationModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    await messageRef.set({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    await _firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Future<String> createConversation({
    required String artistId,
    required String clientId,
    required String artistName,
    required String clientName,
  }) async {
    final existing = await _firestore
        .collection('conversations')
        .where('artistId', isEqualTo: artistId)
        .where('clientId', isEqualTo: clientId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final docRef = _firestore.collection('conversations').doc();

    await docRef.set({
      'artistId': artistId,
      'clientId': clientId,
      'artistName': artistName,
      'clientName': clientName,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadArtist': 0,
      'unreadClient': 0,
    });

    return docRef.id;
  }
}