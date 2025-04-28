import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tufan_rider/features/auth/cubit/auth_state.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';
import 'package:tufan_rider/features/auth/repository/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  LoginResponse? _loginResponse;

  Future<void> initialize() async {
    try {
      final response = await getSavedLoginResponse();
      if (response != null) {
        print('SAVING');
        _loginResponse = response;
        emit(AuthSuccess(response)); // Emit state instead of setting property
      }
    } catch (e) {
      print('Initialization error: $e');
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final data = await _repository.login(email, password);
      await saveLoginResponse(data);
      _loginResponse = data;

      emit(AuthSuccess(data)); // Store in state
    } catch (e) {
      emit(AuthFailure(e.toString()));
      rethrow;
    }
  }

  Future<void> saveLoginResponse(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_data', jsonEncode(response.toJson()));
  }

  Future<LoginResponse?> getSavedLoginResponse() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('login_data');
    return data != null ? LoginResponse.fromJson(jsonDecode(data)) : null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AuthInitial()); // Reset to initial state
  }

  // Update the user within the loginResponse
  void updateUser(User updatedUser) {
    if (_loginResponse != null) {
      // Create a new LoginResponse with the updated user
      final updatedLoginResponse = _loginResponse!.copyWith(user: updatedUser);

      // Update the loginResponse locally
      _loginResponse = updatedLoginResponse;

      saveLoginResponse(_loginResponse!);

      // Emit the new AuthSuccess state with the updated loginResponse
      // emit(AuthSuccess(updatedLoginResponse));
    }
  }

  // Add this getter to easily access the response
  LoginResponse? get loginResponse => _loginResponse;
}
