import 'package:flutter/material.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/permission_checker.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  Future<void> _handlePermissionCheck(BuildContext context) async {
    final granted = await PermissionChecker.requestAllPermissions();
    if (granted) {
      Navigator.pushReplacementNamed(context, AppRoutes.splash);
    } else {
      CustomToast.show(
        'Please allow all permissions to continue using the app',
        context: context,
        toastType: ToastType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text(
                'Permissions Required',
                style: AppTypography.labelText.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Replace the Image.asset with this Icon-based solution
              Icon(
                Icons.verified_user_outlined,
                size: 120,
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 32),

              // Permission List
              _buildPermissionItem(context, Icons.location_on, 'Location',
                  'For ride tracking and navigation'),
              const SizedBox(height: 16),
              _buildPermissionItem(context, Icons.phone, 'Phone',
                  'For emergency calls and verification'),
              const SizedBox(height: 16),
              _buildPermissionItem(context, Icons.photo_library, 'Storage',
                  'For uploading documents and profile pictures'),
              const SizedBox(height: 32),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () => _handlePermissionCheck(context),
                  backgroundColor: AppColors.primaryColor,
                  textColor: AppColors.backgroundColor,
                  text: 'Grant Permissions',
                ),
              ),
              const SizedBox(height: 16),

              // Secondary Option
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.splash),
                child: Text(
                  'Continue with limited functionality',
                  style: AppTypography.labelText.copyWith(
                    color: AppColors.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(
      BuildContext context, IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.labelText.copyWith(
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
