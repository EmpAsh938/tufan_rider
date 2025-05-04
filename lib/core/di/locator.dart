import 'package:get_it/get_it.dart';

import 'package:tufan_rider/core/network/dio_client.dart';
import 'package:tufan_rider/core/network/api_service.dart';
import 'package:tufan_rider/features/auth/cubit/forgot_password_cubit.dart';
import 'package:tufan_rider/features/auth/cubit/registration_cubit.dart';
import 'package:tufan_rider/features/auth/repository/auth_repository.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/core/cubit/theme/theme_cubit.dart';
import 'package:tufan_rider/features/global_cubit/mode_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket.cubit.dart';
import 'package:tufan_rider/features/map/repository/map_repository.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_rider_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_vehicle_cubit.dart';
import 'package:tufan_rider/features/rider/map/repository/rider_repository.dart';
import 'package:tufan_rider/features/sidebar/cubit/update_profile_cubit.dart';

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
  locator.registerLazySingleton<RiderRepository>(
      () => RiderRepository(locator<ApiService>()));

  // Register cubits
  locator.registerLazySingleton<ModeCubit>(() => ModeCubit());
  locator.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  locator.registerLazySingleton<AuthCubit>(
      () => AuthCubit(locator<AuthRepository>()));
  locator.registerLazySingleton<AddressCubit>(
      () => AddressCubit(locator<MapRepository>()));
  locator.registerFactory<RegistrationCubit>(
      () => RegistrationCubit(locator<AuthRepository>()));
  locator.registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(locator<AuthRepository>()));
  locator.registerFactory<StompSocketCubit>(() => StompSocketCubit());
  locator.registerFactory<UpdateProfileCubit>(
      () => UpdateProfileCubit(locator<AuthRepository>()));
  locator.registerFactory<CreateRiderCubit>(
      () => CreateRiderCubit(locator<RiderRepository>()));
  locator.registerFactory<CreateVehicleCubit>(
      () => CreateVehicleCubit(locator<RiderRepository>()));
}
