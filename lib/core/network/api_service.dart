import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tufan_rider/core/network/dio_exceptions.dart';
import 'package:tufan_rider/features/auth/models/registration_request.dart';
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

  Future<Response> requestOTP(String mobileNo) async {
    try {
      final response = await _dio.post(ApiEndpoints.requestOTP, data: {
        'mobileNo': mobileNo,
      });
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> forgotPassword(String mobileNo) async {
    try {
      final response = await _dio.post(ApiEndpoints.forgotPassword, data: {
        'phnum': mobileNo,
      });
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> updatePassword(
      String mobileNo, String otp, String newPassword) async {
    try {
      final response = await _dio.post(ApiEndpoints.updatePassword, data: {
        'phnum': mobileNo,
        'otp': otp,
        'newPassword': newPassword,
      });
      return response;
    } on DioException catch (e) {
      print(e);
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

  Future<Response> uploadProfile(File profileImage, String userId) async {
    try {
      // Prepare the data to be sent as a multipart request
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(profileImage.path,
            filename: profileImage.uri.pathSegments.last),
      });

      // Send the POST request with userId in the URL and the form data
      final response = await Dio().post(
        '${ApiEndpoints.uploadProfile}/$userId', // Append userId in the URL
        data: formData,
      );

      return response;
    } on DioException catch (e) {
      // Handle errors
      throw DioExceptions.fromDioError(e);
    }
  }

  Future<Response> completeRegistration(
      RegistrationRequest registrationRequest) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: registrationRequest,
      );
      print(response);
      return response;
    } on DioException catch (e) {
      print(registrationRequest.toJson());
      throw DioExceptions.fromDioError(e);
    }
  }

  // Add more methods here...
}
