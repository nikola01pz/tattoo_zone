import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(AuthUnauthenticated());
    } else {
      final userType = await _authRepository.getUserType(user.uid);
      emit(AuthAuthenticated(
        uid: user.uid,
        email: user.email!,
        userType: userType,
      ));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      final user = firebase_auth.FirebaseAuth.instance.currentUser!;
      final userType = await _authRepository.getUserType(user.uid);
      emit(AuthAuthenticated(
        uid: user.uid,
        email: user.email!,
        userType: userType,
      ));
    } on firebase_auth.FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Something went wrong. Please try again.'));
}
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        userType: event.userType,
      );
      final user = firebase_auth.FirebaseAuth.instance.currentUser!;
      emit(AuthAuthenticated(
        uid: user.uid,
        email: user.email!,
        userType: event.userType,
      ));
    } on firebase_auth.FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }
}