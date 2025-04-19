import 'package:flutter/material.dart';
import 'package:tufan_rider/features/auth/presentation/screens/login_screen.dart';
import 'package:tufan_rider/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:tufan_rider/features/auth/presentation/screens/signup_screen.dart';
import 'package:tufan_rider/features/map/presentation/screens/address_search_screen.dart';
import 'package:tufan_rider/features/map/presentation/screens/offer_fare_screen.dart';
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
  static const String mapAddressSearch = '/map/address/search';
  static const String mapofferFare = '/map/offerFare';
  static const String profile = '/profile';
  static const String rideHistory = '/ride_history';
  static const String settings = '/settings';
  static const String emergency = '/emergency';

  static Route<dynamic>? generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), routeSettings);
      case login:
        return _slideFromRight(LoginScreen(), routeSettings);
      case signup:
        return _slideFromRight(const RegistrationScreen(), routeSettings);
      case reset:
        return _slideFromRight(const ResetPasswordScreen(), routeSettings);
      case map:
        return _slideFromRight(const MapScreen(), routeSettings);
      case mapAddressSearch:
        return _slideFromRight(const AddressSearchScreen(), routeSettings);
      case mapofferFare:
        return _slideFromBottom(const OfferFareScreen(), routeSettings);
      case profile:
        return _slideFromRight(const ProfileScreen(), routeSettings);
      case rideHistory:
        return _slideFromRight(RideHistoryScreen(), routeSettings);
      case settings:
        return _slideFromRight(SettingsScreen(), routeSettings);
      case emergency:
        return _slideFromRight(EmergencyScreen(), routeSettings);
      default:
        return null;
    }
  }

  static PageRouteBuilder _slideFromRight(
      Widget page, RouteSettings routeSettings) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static PageRouteBuilder _slideFromBottom(
      Widget page, RouteSettings routeSettings) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings routeSettings) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
