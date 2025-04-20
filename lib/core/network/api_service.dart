import 'package:dio/dio.dart';
import 'package:tufan_rider/core/network/dio_exceptions.dart';
import 'dio_client.dart';
import 'api_endpoints.dart';

class ApiService {
  final Dio _dio = DioClient().dio;

  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post(ApiEndpoints.login, data: {
        'username': email,
        'password': password,
      });
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> getUserProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.userProfile);
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  // Add more methods here...
}
