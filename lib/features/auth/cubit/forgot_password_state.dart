import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class OtpSent extends ForgotPasswordState {}

class OtpSendFailure extends ForgotPasswordState {
  final String message;
  const OtpSendFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class OtpVerified extends ForgotPasswordState {}

class OtpVerificationFailed extends ForgotPasswordState {
  final String message;
  const OtpVerificationFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetSuccess extends ForgotPasswordState {}

class PasswordResetFailure extends ForgotPasswordState {
  final String message;
  const PasswordResetFailure(this.message);

  @override
  List<Object?> get props => [message];
}
