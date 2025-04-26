import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/features/auth/cubit/registration_state.dart';
import 'package:tufan_rider/features/auth/models/otp_response.dart';
import 'package:tufan_rider/features/auth/models/registration_request.dart';
import 'package:tufan_rider/features/auth/repository/auth_repository.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  final AuthRepository _repository;

  RegistrationCubit(this._repository) : super(RegistrationInitial());

  OtpResponse? otpResponse;

  Future<void> sendOtp(String phoneNumber) async {
    emit(RegistrationLoading());
    try {
      final data = await _repository.requestOTP(phoneNumber);
      emit(OtpSent());
    } catch (e) {
      emit(OtpSendFailure(e.toString()));
    }
  }

  Future<void> verifyOtp(String emailOrPhone, String otp) async {
    emit(RegistrationLoading());
    try {
      await _repository.verifyOTP(emailOrPhone, otp);
      emit(OtpVerified());
    } catch (e) {
      emit(OtpVerificationFailure(e.toString()));
    }
  }

  Future<void> uploadProfile(File profileImage, String userId) async {
    emit(RegistrationLoading());
    try {
      await _repository.uploadProfile(profileImage, userId);
      emit(ProfileUploaded());
    } catch (e) {
      emit(ProfileUploadFailure(e.toString()));
    }
  }

  Future<void> completeRegistration(
      RegistrationRequest registrationRequest) async {
    emit(RegistrationLoading());
    try {
      final data = await _repository.completeRegistration(registrationRequest);
      emit(RegistrationCompleted(data));
    } catch (e) {
      emit(RegistrationFailure(e.toString()));
    }
  }
}
