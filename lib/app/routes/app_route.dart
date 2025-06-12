import 'package:flutter/material.dart';
import 'package:tufan_rider/features/auth/models/login_response.dart';
import 'package:tufan_rider/features/auth/presentation/screens/login_screen.dart';
import 'package:tufan_rider/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:tufan_rider/features/auth/presentation/screens/signup_screen.dart';
import 'package:tufan_rider/features/map/presentation/screens/address_search_screen.dart';
import 'package:tufan_rider/features/map/presentation/screens/offer_fare_screen.dart';
import 'package:tufan_rider/features/map/presentation/screens/map_screen.dart';
import 'package:tufan_rider/features/permissions/presentation/screens/permission_screen.dart';
import 'package:tufan_rider/features/rider/map/presentation/screens/credit_history.dart';
import 'package:tufan_rider/features/rider/map/presentation/screens/rider_credit_screen.dart';
import 'package:tufan_rider/features/rider/map/presentation/screens/rider_map_screen.dart';
import 'package:tufan_rider/features/rider/map/presentation/screens/rider_registration.dart';
import 'package:tufan_rider/features/rider/map/presentation/screens/rider_signupflow.dart';
import 'package:tufan_rider/features/rider/map/presentation/screens/rider_updateflow.dart';
import 'package:tufan_rider/features/sidebar/presentation/screens/change_phone_screen.dart';
import 'package:tufan_rider/features/sidebar/presentation/screens/emergency_screen.dart';
import 'package:tufan_rider/features/sidebar/presentation/screens/profile_screen.dart';
import 'package:tufan_rider/features/sidebar/presentation/screens/ride_history_screen.dart';
import 'package:tufan_rider/features/sidebar/presentation/screens/settings_screen.dart';
import 'package:tufan_rider/features/sidebar/presentation/screens/support_screen.dart';
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
  static const String changePhone = '/settings/changePhone';
  static const String emergency = '/emergency';
  static const String support = '/support';
  static const String riderSignupFlow = '/riderSignup';
  static const String riderUpdateflow = '/riderUpdate';
  static const String riderCredit = '/riderCredit';
  static const String riderCreditHistory = '/riderCreditHistory';
  static const String permissionScreen = '/permissions';

  static Route<dynamic>? generateRoute(
      RouteSettings routeSettings, LoginResponse? loginResponse) {
    switch (routeSettings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), routeSettings);
      case permissionScreen:
        return _fadeRoute(const PermissionScreen(), routeSettings);
      case login:
        return _slideFromRight(LoginScreen(), routeSettings);
      case signup:
        return _slideFromRight(const RegistrationScreen(), routeSettings);
      case reset:
        return _slideFromRight(const ResetPasswordScreen(), routeSettings);
      case riderSignupFlow:
        return _slideFromRight(const RiderSignupflow(), routeSettings);
      case riderUpdateflow:
        return _slideFromRight(const RiderUpdateflow(), routeSettings);
      case riderCredit:
        return _slideFromRight(const RiderCreditScreen(), routeSettings);
      case riderCreditHistory:
        return _slideFromRight(const CreditHistory(), routeSettings);
      case map:
        final modes = loginResponse!.user.modes.toLowerCase();
        final roleId = loginResponse.user.roles.first.id.toString();

        if (modes == 'rider') {
          // if (roleId == '504') {
          //   return _slideFromRight(const RiderMapScreen(), routeSettings);
          // }
          return _slideFromRight(const RiderRegistration(), routeSettings);
        } else {
          return _slideFromRight(const MapScreen(), routeSettings);
        }
      case mapAddressSearch:
        return _slideFromRight(const AddressSearchScreen(), routeSettings);
      case mapofferFare:
        return _slideFromBottom(
            const OfferFareScreen(
              categoryId: '1',
            ),
            routeSettings);
      case profile:
        return _slideFromRight(const ProfileScreen(), routeSettings);
      case rideHistory:
        return _slideFromRight(RideHistoryScreen(), routeSettings);
      case settings:
        return _slideFromRight(SettingsScreen(), routeSettings);
      case changePhone:
        return _slideFromRight(ChangePhoneScreen(), routeSettings);
      case emergency:
        return _slideFromRight(EmergencyScreen(), routeSettings);
      case support:
        return _slideFromRight(SupportScreen(), routeSettings);
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
