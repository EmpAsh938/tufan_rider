import 'package:equatable/equatable.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';

abstract class UpdateProfileState extends Equatable {
  const UpdateProfileState();

  @override
  List<Object?> get props => [];
}

class UpdateProfileInitial extends UpdateProfileState {}

class UpdateProfileLoading extends UpdateProfileState {}

class UpdateProfileUploadLoading extends UpdateProfileState {}

class UpdateProfileUploadSuccess extends UpdateProfileState {
  final User user;

  const UpdateProfileUploadSuccess(this.user);
}

class UpdateProfileUploadFailure extends UpdateProfileState {
  final String message;

  const UpdateProfileUploadFailure(this.message);
}

class UpdateProfileSuccess extends UpdateProfileState {
  final User user;

  const UpdateProfileSuccess(this.user);
}

class UpdateProfileFailure extends UpdateProfileState {
  final String message;

  const UpdateProfileFailure(this.message);
}
