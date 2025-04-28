import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/features/auth/repository/auth_repository.dart';
import 'package:tufan_rider/features/sidebar/cubit/update_profile_state.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  final AuthRepository _repository;
  UpdateProfileCubit(this._repository) : super(UpdateProfileInitial());

  Future<void> uploadProfile(
    File profileImage,
    String userId,
    String token,
  ) async {
    try {
      emit(UpdateProfileLoading());
      final data = await _repository.uploadProfile(
        profileImage,
        userId,
        token,
      );
      emit(UpdateProfileUploadSuccess(data));
    } catch (e) {
      emit(UpdateProfileUploadFailure(e.toString()));
    }
  }

  Future<void> updateProfile(
    String userId,
    String token,
    String email,
    String phone,
    String password,
  ) async {
    try {
      emit(UpdateProfileLoading());
      final data = await _repository.updateProfile(
        userId,
        token,
        email,
        phone,
        password,
      );
      if (data == null) {
        emit(UpdateProfileFailure('Update profile failed'));
      }
      //  update user
      emit(UpdateProfileSuccess(data));
    } catch (e) {
      print(e);
      emit(UpdateProfileFailure(e.toString()));
    }
  }
}
