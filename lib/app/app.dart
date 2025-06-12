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
import 'package:tufan_rider/features/map/cubit/address_cubit.dart';
import 'package:tufan_rider/features/map/cubit/emergency_cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket.cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_rider_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_vehicle_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/propose_price_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/ride_request_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/rider_payment_cubit.dart';
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
        BlocProvider<CreateRiderCubit>(
          create: (context) => locator<CreateRiderCubit>(),
        ),
        BlocProvider<CreateVehicleCubit>(
          create: (context) => locator<CreateVehicleCubit>(),
        ),
        BlocProvider<RideRequestCubit>(
          create: (context) => locator<RideRequestCubit>(),
        ),
        BlocProvider<ProposePriceCubit>(
          create: (context) => locator<ProposePriceCubit>(),
        ),
        BlocProvider<EmergencyCubit>(
          create: (context) => locator<EmergencyCubit>(),
        ),
        BlocProvider<RiderPaymentCubit>(
          create: (context) => locator<RiderPaymentCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, theme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            title: 'Tufan Ride Share',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: theme.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) {
              final loginResponse = context.read<AuthCubit>().loginResponse;

              return AppRoutes.generateRoute(settings, loginResponse);
            },
          );
        },
      ),
    );
  }
}
