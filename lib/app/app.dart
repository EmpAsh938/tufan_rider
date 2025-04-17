import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/cubit/theme/theme_cubit.dart';
import 'package:tufan_rider/core/cubit/theme/theme_state.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/core/themes/app_theme.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => locator<ThemeCubit>(),
        ),
        BlocProvider<AddressCubit>(
          create: (context) => locator<AddressCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Tufan Ride Share',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: state.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
