import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ArtistHomePage extends StatelessWidget {
  const ArtistHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artist'), actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => FirebaseAuth.instance.signOut(),
        )
      ]),
      body: const Center(child: Text('Artist Homepage')),
    );
  }
}