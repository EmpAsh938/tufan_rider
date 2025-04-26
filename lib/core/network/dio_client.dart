import 'package:dio/dio.dart';
import 'package:tufan_rider/app/app.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/network/dio_exceptions.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';

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
          final error = DioExceptions.fromDioError(e);

          print("❌ ERROR: ${error.message}");

          if (e.response?.statusCode == 401) {
            locator.get<AuthCubit>().logout();

            navigatorKey.currentState
                ?.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
          }
          return handler.next(e);
        },
      ),
    );
  }
}
