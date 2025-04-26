import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  final String message;

  DioExceptions._(this.message);

  factory DioExceptions.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return DioExceptions._("Connection timeout.");
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return DioExceptions._("Receive timeout.");
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        return DioExceptions._handleBadResponse(
          statusCode,
          responseData,
        );

      case DioExceptionType.cancel:
        return DioExceptions._("Request to API server was cancelled.");
      case DioExceptionType.unknown:
      default:
        return DioExceptions._("Unexpected error occurred.");
    }
  }

  static DioExceptions _handleBadResponse(int? statusCode, dynamic data) {
    switch (statusCode) {
      case 400:
        return DioExceptions._(_getMessage(data));
      case 401:
        return DioExceptions._("Unauthorized request. Please log in again.");
      case 403:
        return DioExceptions._("Access denied.");

      case 405:
        return DioExceptions._("Method not allowed.");
      case 408:
        return DioExceptions._("Request timeout.");
      case 409:
        return DioExceptions._("Conflict. ${_getMessage(data)}");
      case 422:
        return DioExceptions._("Validation error. ${_getMessage(data)}");
      case 429:
        return DioExceptions._("Too many requests. Please slow down.");
      case 500:
        return DioExceptions._("Internal server error.");
      case 502:
        return DioExceptions._("Bad gateway.");
      case 503:
        return DioExceptions._("Service unavailable.");
      case 504:
        return DioExceptions._("Gateway timeout.");
      default:
        return DioExceptions._("Received invalid status code: $statusCode");
    }
  }

  static String _getMessage(dynamic data) {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return '';
  }

  @override
  String toString() => message;
}
