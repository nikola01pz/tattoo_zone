import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tattoo_zona/pages/client_home_page.dart';
import 'package:tattoo_zona/pages/artist_home_page.dart';
import 'package:tattoo_zona/pages/login_or_register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginOrRegisterPage();
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator()
                )
              );
            }

            if (userSnapshot.data!.exists && userSnapshot.data!['userType'] == 'artist') {
              return const ArtistHomePage();
            }

            return const ClientHomePage();
          },
        );
      },
    );
  }
}