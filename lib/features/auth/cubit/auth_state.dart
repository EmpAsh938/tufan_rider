import 'package:equatable/equatable.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final LoginResponse loginResponse;

  const AuthSuccess(this.loginResponse);

  @override
  List<Object?> get props => [loginResponse];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
