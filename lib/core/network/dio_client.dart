import 'package:dio/dio.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/network/dio_exceptions.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  late Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // You can add authorization headers here
          print("➡️ ${options.method} ${options.uri}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("✅ RESPONSE: ${response.statusCode} ${response.data}");
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          try {
            print("❌ RAW ERROR RESPONSE: ${e.response?.data}");

            final parsed = DioExceptions.fromDioError(e);
            print("❌ HANDLED ERROR: ${parsed.message}");
          } catch (e) {
            print("❌ ERROR HANDLING FAILURE: ${e.toString()}");
          }

          return handler.next(e);
        },
      ),
    );
  }
}
