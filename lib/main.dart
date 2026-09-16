import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tattoo_zona/features/auth/bloc/auth_event.dart';
import 'package:tattoo_zona/features/artist/bloc/artist_bloc.dart';
import 'package:tattoo_zona/features/artist/bloc/appointment_bloc.dart';
import 'package:tattoo_zona/features/shared/data/appointment_repository.dart';
import 'firebase_options.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/pages/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            authRepository: AuthRepository(),
          )..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => ArtistBloc(),
        ),
        BlocProvider(
          create: (_) => AppointmentBloc(
            repository: AppointmentRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey[300],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[300],
            elevation: 0,
          ),
        ),
        home: const AuthPage(),
      ),
    );
  }
}