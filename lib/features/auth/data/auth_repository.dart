import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signIn({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String userType,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'email': email,
      'userType': userType,
    });

    if (userType == 'artist') {
    await _firestore.collection('artists').doc(credential.user!.uid).set({
      'displayName': '',        
      'bio': '',
      'styles': [],
      'location': null,
      'locationName': '',
      'profileImageUrl': '',
      'portfolioImages': [],
      'rating': 0.0,
      'reviewCount': 0,
      });
    }

    if (userType == 'client') {
      await _firestore.collection('clients').doc(credential.user!.uid).set({
        'displayName': '',
        'profileImageUrl': '',
        'locationName': '',
        'bio': '',
        'currentTattoos': [],
      });
    }
  }

  Future<String> getUserType(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['userType'] ?? 'client';
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}