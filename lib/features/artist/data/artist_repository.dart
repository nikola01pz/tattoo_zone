import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tattoo_zona/features/shared/models/artist_model.dart';

class ArtistRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

Future<ArtistModel> getArtist() async {
  final uid = _auth.currentUser!.uid;
  final doc = await _firestore.collection('artists').doc(uid).get();
  return ArtistModel.fromFirestore(doc.data()!, doc.id);
}

Future<void> updateArtist(ArtistModel artist) async {
  await _firestore
      .collection('artists')
      .doc(artist.id)
      .update(artist.toMap());
}
}