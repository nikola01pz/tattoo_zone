import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tattoo_zona/features/shared/models/tattoo_model.dart';
import 'package:tattoo_zona/features/shared/models/artist_model.dart';
import 'package:tattoo_zona/features/shared/models/client_model.dart';

class ClientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<TattooModel>> getTattoos() async {
    final snapshot = await _firestore
        .collection('tattoos')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => TattooModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<ArtistModel>> getArtists() async {
    final snapshot = await _firestore.collection('artists').get();
    return snapshot.docs
        .map((doc) => ArtistModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

Future<ClientModel> getClient() async {
  final uid = _auth.currentUser!.uid;
  final doc = await _firestore.collection('clients').doc(uid).get();
  
  if (!doc.exists || doc.data() == null) {
    return ClientModel(
      id: uid,
      displayName: '',
      profileImageUrl: '',
      locationName: '',
      bio: '',
      currentTattoos: [],
    );
  }
  
  return ClientModel.fromFirestore(doc.data()!, doc.id);
}

Future<void> updateClient(ClientModel client) async {
  final uid = _auth.currentUser!.uid;
  await _firestore
      .collection('clients')
      .doc(uid)
      .set(client.toMap(), SetOptions(merge: true));
}
}