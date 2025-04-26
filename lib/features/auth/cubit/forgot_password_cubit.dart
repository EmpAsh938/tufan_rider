import 'package:bloc/bloc.dart';
import 'package:tufan_rider/features/auth/cubit/forgot_password_state.dart';
import 'package:tufan_rider/features/auth/repository/auth_repository.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository _repository;

  ForgotPasswordCubit(this._repository) : super(ForgotPasswordInitial());

  Future<void> sendOtp(String emailOrPhone) async {
    emit(ForgotPasswordLoading());
    try {
      await _repository.forgotPassword(emailOrPhone);
      emit(OtpSent());
    } catch (e) {
      emit(OtpSendFailure(e.toString()));
    }
  }

  Future<void> verifyOtp(String emailOrPhone, String otp) async {
    emit(ForgotPasswordLoading());
    try {
      await _repository.verifyOTP(emailOrPhone, otp);

      emit(OtpVerified());
    } catch (e) {
      emit(OtpVerificationFailed(e.toString()));
    }
  }

  Future<void> resetPassword(
      String emailOrPhone, String otp, String newPassword) async {
    emit(ForgotPasswordLoading());
    try {
      // Simulate reset
      await _repository.updatePassword(emailOrPhone, otp, newPassword);
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(PasswordResetFailure(e.toString()));
    }
  }
}
