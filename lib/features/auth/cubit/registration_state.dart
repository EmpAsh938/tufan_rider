import 'package:equatable/equatable.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object?> get props => [];
}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class OtpSent extends RegistrationState {}

class OtpSendFailure extends RegistrationState {
  final String message;

  const OtpSendFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class OtpVerified extends RegistrationState {}

class OtpVerificationFailure extends RegistrationState {
  final String message;

  const OtpVerificationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUploaded extends RegistrationState {}

class ProfileUploadFailure extends RegistrationState {
  final String message;

  const ProfileUploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class RegistrationCompleted extends RegistrationState {
  final User user;

  const RegistrationCompleted(this.user);

  @override
  List<Object?> get props => [user];
}

class RegistrationFailure extends RegistrationState {
  final String message;

  const RegistrationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
