import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  final String message;
  final dynamic data;
  final int? statusCode;

  DioExceptions._(this.message, {this.data, this.statusCode});

  factory DioExceptions.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return DioExceptions._("Connection timeout with server");
      case DioExceptionType.sendTimeout:
        return DioExceptions._("Send timeout in connection with server");
      case DioExceptionType.receiveTimeout:
        return DioExceptions._("Receive timeout in connection with server");
      case DioExceptionType.badResponse:
        return _handleResponse(error);
      case DioExceptionType.cancel:
        return DioExceptions._("Request to server was cancelled");
      case DioExceptionType.connectionError:
        return DioExceptions._("Connection failed. Please check your internet");
      case DioExceptionType.unknown:
        return _handleUnknownError(error);
      case DioExceptionType.badCertificate:
        return DioExceptions._("SSL certificate verification failed");
    }
  }

  static DioExceptions _handleUnknownError(DioException error) {
    // Handle null error cases
    if (error.error == null && error.response == null) {
      return DioExceptions._("No response received from server");
    }

    // Handle socket exceptions (no internet)
    if (error.error is SocketException) {
      return DioExceptions._("No internet connection");
    }

    // Handle format exceptions (parsing errors)
    if (error.error is FormatException) {
      return DioExceptions._("Invalid server response format");
    }

    // Handle other unknown errors
    final errorMessage = error.message;
    return DioExceptions._(
      errorMessage != null && errorMessage.isNotEmpty
          ? errorMessage
          : "An unknown error occurred",
    );
  }

  static DioExceptions _handleResponse(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final dynamic data = response?.data;

    // Handle null response
    if (response == null) {
      return DioExceptions._("Empty response received", statusCode: statusCode);
    }

    // Handle null or empty data
    if (data == null || data.toString().trim().isEmpty) {
      return DioExceptions._(
        statusCode != null
            ? "Empty response received (status: $statusCode)"
            : "Empty response received",
        statusCode: statusCode,
      );
    }

    // Handle string responses
    if (data is String) {
      // Skip JSON parsing for very long strings (likely HTML error pages)
      if (data.length > 500 && data.contains('<!DOCTYPE html>')) {
        return DioExceptions._(
          "Server error (status: $statusCode)",
          data: data,
          statusCode: statusCode,
        );
      }

      try {
        // Try to parse as JSON only if it looks like JSON
        if (data.trim().startsWith('{') || data.trim().startsWith('[')) {
          final json = jsonDecode(data);
          if (json is Map) {
            return DioExceptions._(
              json['message'] ??
                  json['error'] ??
                  json['detail'] ??
                  "Request failed (status: $statusCode)",
              data: json,
              statusCode: statusCode,
            );
          }
        }
        return DioExceptions._(data, data: data, statusCode: statusCode);
      } catch (e) {
        // If parsing fails, return the raw string
        return DioExceptions._(data, data: data, statusCode: statusCode);
      }
    }

    // Handle Map responses (already parsed JSON)
    if (data is Map) {
      return DioExceptions._(
        data['message'] ??
            data['error'] ??
            data['detail'] ??
            "Request failed (status: $statusCode)",
        data: data,
        statusCode: statusCode,
      );
    }

    // Handle other types
    return DioExceptions._(
      "Unexpected response format (status: $statusCode)",
      data: data,
      statusCode: statusCode,
    );
  }

  @override
  String toString() => message;
}
