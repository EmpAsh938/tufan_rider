import 'package:get_it/get_it.dart';
import 'package:tufan_rider/core/cubit/theme/theme_cubit.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register BLoCs
  locator.registerLazySingleton(() => ThemeCubit());

  // Register services/repositories
  // locator.registerLazySingleton(() => AuthRepository());
}
