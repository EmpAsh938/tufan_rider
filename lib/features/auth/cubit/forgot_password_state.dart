import 'package:equatable/equatable.dart';
import 'package:tufan_rider/features/auth/models/forgot_password_response.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class OtpSent extends ForgotPasswordState {
  final ForgotPasswordResponse forgotPasswordResponse;
  const OtpSent(this.forgotPasswordResponse);

  @override
  List<Object?> get props => [forgotPasswordResponse];
}

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
