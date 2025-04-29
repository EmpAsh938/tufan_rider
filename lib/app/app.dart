import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/cubit/theme/theme_cubit.dart';
import 'package:tufan_rider/core/cubit/theme/theme_state.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/core/themes/app_theme.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/auth/cubit/forgot_password_cubit.dart';
import 'package:tufan_rider/features/auth/cubit/registration_cubit.dart';
import 'package:tufan_rider/features/global_cubit/mode_cubit.dart';
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket.cubit.dart';
import 'package:tufan_rider/features/sidebar/cubit/update_profile_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => locator<ThemeCubit>(),
        ),
        BlocProvider<ModeCubit>(
          create: (context) => locator<ModeCubit>(),
        ),
        BlocProvider<AuthCubit>(
          create: (context) => locator<AuthCubit>(),
        ),
        BlocProvider<RegistrationCubit>(
          create: (context) => locator<RegistrationCubit>(),
        ),
        BlocProvider<ForgotPasswordCubit>(
          create: (context) => locator<ForgotPasswordCubit>(),
        ),
        BlocProvider<AddressCubit>(
          create: (context) => locator<AddressCubit>(),
        ),
        BlocProvider<StompSocketCubit>(
          create: (context) => locator<StompSocketCubit>(),
        ),
        BlocProvider<UpdateProfileCubit>(
          create: (context) => locator<UpdateProfileCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, theme) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Tufan Ride Share',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: theme.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) {
              final mode = context.read<ModeCubit>().state;

              return AppRoutes.generateRoute(settings, mode);
            },
          );
        },
      ),
    );
  }
}
