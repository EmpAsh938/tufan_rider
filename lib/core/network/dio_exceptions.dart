import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  final String message;

  DioExceptions._(this.message);

  factory DioExceptions.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return DioExceptions._("Connection timeout.");
      case DioExceptionType.sendTimeout:
        return DioExceptions._("Send timeout.");
      case DioExceptionType.receiveTimeout:
        return DioExceptions._("Receive timeout.");
      case DioExceptionType.badResponse:
        return DioExceptions._(
            "Received invalid status code: ${error.response?.statusCode}");
      case DioExceptionType.cancel:
        return DioExceptions._("Request to API server was cancelled.");
      case DioExceptionType.unknown:
      default:
        return DioExceptions._("Unexpected error occurred.");
    }
  }

  @override
  String toString() => message;
}
