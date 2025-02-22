import 'package:flutter/material.dart';
import 'package:tufan_rider/features/auth/presentation/screens/login_screen.dart';
import 'package:tufan_rider/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:tufan_rider/features/auth/presentation/screens/signup_screen.dart';
import 'package:tufan_rider/features/map/presentation/screens/map_screen.dart';
import 'package:tufan_rider/features/sidebar/presentation/screens/emergency_screen.dart';
import 'package:tufan_rider/features/sidebar/presentation/screens/profile_screen.dart';
import 'package:tufan_rider/features/sidebar/presentation/screens/ride_history_screen.dart';
import 'package:tufan_rider/features/sidebar/presentation/screens/settings_screen.dart';
import 'package:tufan_rider/features/splash/presentation/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String reset = '/reset';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String rideHistory = '/ride_history';
  static const String settings = '/settings';
  static const String emergency = '/emergency';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => LoginScreen(),
      signup: (context) => const RegistrationScreen(),
      reset: (context) => const ResetPasswordScreen(),
      map: (context) => const MapBookingScreen(),
      profile: (context) => const ProfileScreen(),
      rideHistory: (context) => RideHistoryScreen(),
      settings: (context) => SettingsScreen(),
      emergency: (context) => EmergencyScreen(),
    };
  }
}
