import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tattoo_zona/features/auth/bloc/auth_bloc.dart';
import 'package:tattoo_zona/features/auth/bloc/auth_event.dart';

class ArtistHomePage extends StatelessWidget {
  const ArtistHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artist'), actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
        )
      ]),
      body: const Center(child: Text('Artist Homepage')),
    );
  }
}