import 'package:equatable/equatable.dart'; 

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String uid;
  final String email;
  final String userType;
  const AuthAuthenticated({
    required this.uid,
    required this.email,
    required this.userType,
  });
  @override
  List<Object?> get props => [uid, email, userType];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}