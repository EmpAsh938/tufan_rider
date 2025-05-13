import 'package:flutter/material.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/core/utils/permission_checker.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final AuthCubit authCubit;

  @override
  void initState() {
    super.initState();
    authCubit = locator.get<AuthCubit>();

    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    authCubit.initialize();

    // Check permissions
    await PermissionChecker.checkLocationPermission();
    await PermissionChecker.checkCallPermission();
    await PermissionChecker.checkGalleryPermission();

    await Future.delayed(const Duration(seconds: 2));

    final loginResponse = authCubit.loginResponse;

    if (!mounted) return;

    if (loginResponse == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.map);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Assets.logo.image(),
            Column(
              children: [
                Text(
                  'Ride Smart || Travel Safe',
                  style: AppTypography.headline,
                ),
                Text(
                  'Your Travel Partner',
                  style: AppTypography.headline,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
