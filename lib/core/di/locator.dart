import 'package:get_it/get_it.dart';

import 'package:tufan_rider/core/network/dio_client.dart';
import 'package:tufan_rider/core/network/api_service.dart';
import 'package:tufan_rider/features/auth/repository/auth_repository.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/core/cubit/theme/theme_cubit.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register core services
  locator.registerLazySingleton<DioClient>(() => DioClient());
  locator.registerLazySingleton<ApiService>(() => ApiService());

  // Register repositories
  locator.registerLazySingleton<AuthRepository>(
      () => AuthRepository(locator<ApiService>()));

  // Register cubits
  locator.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  locator
      .registerFactory<AuthCubit>(() => AuthCubit(locator<AuthRepository>()));
}
