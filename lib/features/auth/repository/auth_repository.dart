import 'dart:convert';

import 'package:tufan_rider/core/network/api_service.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<LoginResponse> login(String email, String password) async {
    final response = await _apiService.login(email, password);

    return LoginResponse.fromJson(response.data);
  }
}
