import 'package:get_it/get_it.dart';

import 'package:tufan_rider/core/network/dio_client.dart';
import 'package:tufan_rider/core/network/api_service.dart';
import 'package:tufan_rider/features/auth/cubit/forgot_password_cubit.dart';
import 'package:tufan_rider/features/auth/cubit/registration_cubit.dart';
import 'package:tufan_rider/features/auth/repository/auth_repository.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/core/cubit/theme/theme_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/repository/map_repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register core services
  locator.registerLazySingleton<DioClient>(() => DioClient());
  locator.registerLazySingleton<ApiService>(() => ApiService());

  // Register repositories
  locator.registerLazySingleton<AuthRepository>(
      () => AuthRepository(locator<ApiService>()));
  locator.registerLazySingleton<MapRepository>(
      () => MapRepository(locator<ApiService>()));

  // Register cubits
  locator.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  locator.registerLazySingleton<AuthCubit>(
      () => AuthCubit(locator<AuthRepository>()));
  locator.registerLazySingleton<AddressCubit>(
      () => AddressCubit(locator<MapRepository>()));
  locator.registerFactory<RegistrationCubit>(
      () => RegistrationCubit(locator<AuthRepository>()));
  locator.registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(locator<AuthRepository>()));
}
