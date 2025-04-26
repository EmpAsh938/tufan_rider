import 'dart:io';

import 'package:tufan_rider/core/network/api_service.dart';
import 'package:tufan_rider/features/auth/models/forgot_password_response.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';
import 'package:tufan_rider/features/auth/models/otp_response.dart';
import 'package:tufan_rider/features/auth/models/registration_request.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<LoginResponse> login(String email, String password) async {
    final response = await _apiService.login(email, password);

    return LoginResponse.fromJson(response.data);
  }

  Future<void> requestOTP(String mobileNo) async {
    final response = await _apiService.requestOTP(mobileNo);
    // return OtpResponse.fromJson(response.data);
  }

  Future<void> verifyOTP(String emailOrPhone, String otp) async {
    final response = await _apiService.verifyOTP(emailOrPhone, otp);
    // return OtpResponse.fromJson(response.data);
  }

  Future<void> forgotPassword(String mobileNo) async {
    final response = await _apiService.forgotPassword(mobileNo);
    // return ForgotPasswordResponse.fromJson(response.data);
  }

  Future<void> updatePassword(
      String mobileNo, String otp, String newPassword) async {
    await _apiService.updatePassword(mobileNo, otp, newPassword);
    // return ForgotPasswordResponse.fromJson(response.data);
  }

  Future<User> completeRegistration(
      RegistrationRequest registrationRequest) async {
    final response =
        await _apiService.completeRegistration(registrationRequest);
    return User.fromJson(response.data);
  }

  Future<void> uploadProfile(File profileImage, String userId) async {
    await _apiService.uploadProfile(profileImage, userId);
  }
}
