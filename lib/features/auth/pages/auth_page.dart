import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tattoo_zona/features/auth/bloc/auth_state.dart';
import '../bloc/auth_bloc.dart';
import 'login_or_register_page.dart';
import '../../client/pages/client_home_page.dart';
import '../../artist/pages/artist_home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthAuthenticated) {
          return state.userType == 'artist'
              ? const ArtistHomePage()
              : const ClientHomePage();
        }
        return const LoginOrRegisterPage();
      },
    );
  }
}