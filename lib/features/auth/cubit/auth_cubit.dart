import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';
import 'package:tufan_rider/features/auth/repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  LoginResponse? loginResponse;

  Future<void> initialize() async {
    try {
      final response = await getSavedLoginResponse();
      if (response != null) {
        loginResponse = response;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final data = await _repository.login(email, password);
      loginResponse = data;
      if (loginResponse != null) {
        await saveLoginResponse(loginResponse!);
        emit(AuthSuccess(data));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> saveLoginResponse(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('login_data', jsonEncode(response.toJson()));
  }

  Future<LoginResponse?> getSavedLoginResponse() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('login_data');
    if (data != null) {
      return LoginResponse.fromJson(jsonDecode(data));
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    loginResponse = null;
    await prefs.clear();
  }
}
