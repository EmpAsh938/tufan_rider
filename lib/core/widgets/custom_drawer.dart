import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/utils/custom_toast.dart';
import 'package:tufan_rider/core/utils/text_utils.dart';
import 'package:tufan_rider/core/widgets/custom_switch.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/rider/map/cubit/create_rider_cubit.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  void _showOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.primaryWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  Icon(Icons.person_outline, color: AppColors.primaryColor),
              title: Text(
                'View Profile',
                style: AppTypography.labelText.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                // Close drawer if coming from drawer
                // Scaffold.of(context).closeDrawer();

                // Close modal if coming from modal
                Navigator.pop(context);

                // Navigate to profile
                Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.logout, color: AppColors.primaryRed),
              title: Text(
                'Logout',
                style: AppTypography.labelText.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryRed,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close modal
                showLogoutDialog(context);
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              child: Text(
                'Cancel',
                style: AppTypography.labelText.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          backgroundColor: AppColors.backgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                "Are you sure you want to log out?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: AppColors.primaryBlack.withOpacity(0.5),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      // Scaffold.of(context).closeDrawer();

                      Navigator.pop(context); // Close dialog

                      // ✅ Clear all routes and push login screen
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );

                      locator.get<AuthCubit>().logout();
                    },
                    child: const Text("Logout",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final riderResponse = context.read<CreateRiderCubit>().riderResponse;

    final loginResponse = authCubit.loginResponse;
    final isInActive = riderResponse?.status.toLowerCase() != 'active';

    return Drawer(
      backgroundColor: AppColors.backgroundColor,
      child: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 14.0,
                  top: 10.0,
                  bottom: 50.0, // Add bottom padding to avoid overlap
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primaryColor,
                          backgroundImage:
                              (loginResponse?.user.imageName != null &&
                                      loginResponse!.user.imageName!.isNotEmpty)
                                  ? NetworkImage(ApiEndpoints.baseUrl +
                                      ApiEndpoints.getImage(
                                          loginResponse.user.imageName!))
                                  : null,
                          child: (loginResponse?.user.imageName == null ||
                                  loginResponse!.user.imageName!.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.primaryBlack,
                                )
                              : null,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loginResponse == null
                                  ? ''
                                  : TextUtils.capitalizeEachWord(
                                      loginResponse.user.name),
                              style: AppTypography.labelText.copyWith(
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(
                                height:
                                    4), // Small spacing between name and rating
                            if (loginResponse!.user.modes.toLowerCase() ==
                                'rider')
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RatingBar.builder(
                                    initialRating:
                                        4.5, // Replace with actual user rating
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 16,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 1.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: AppColors.primaryColor,
                                    ),
                                    onRatingUpdate: (rating) {
                                      // Handle rating updates if needed
                                    },
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '4.5', // Replace with actual user rating
                                    style: AppTypography.labelText.copyWith(
                                      color: AppColors.primaryBlack
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            _showOptionsModal(context);
                          },
                          icon: Icon(Icons.more_vert_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (loginResponse.user.modes.toLowerCase() == 'rider') ...[
                      _buildDrawerButton('Internal Rides', () {
                        Scaffold.of(context).closeDrawer();
                        // if (isInActive) {
                        //   CustomToast.show(
                        //     'You need to be registered and active to use the feature',
                        //     context: context,
                        //     toastType: ToastType.info,
                        //   );
                        //   return;
                        // }
                        Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.map, (route) => false);
                      }),
                      // _buildDrawerButton('City to City', () {
                      //   Scaffold.of(context).closeDrawer();
                      //   Navigator.pushNamed(context, AppRoutes.rideHistory);
                      // }),
                      _buildDrawerButton('Tufan Credits', () {
                        Scaffold.of(context).closeDrawer();
                        if (!isInActive) {
                          CustomToast.show(
                            'You need to be registered and active to use the feature',
                            context: context,
                            toastType: ToastType.info,
                          );
                          return;
                        }
                        Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.riderCredit, (route) => false);
                      }),
                      // _buildDrawerButton('Tufan Fund', () {
                      //   Scaffold.of(context).closeDrawer();
                      //   Navigator.pushNamed(context, AppRoutes.rideHistory);
                      // }),
                    ],
                    _buildDrawerButton('Ride History', () {
                      Scaffold.of(context).closeDrawer();
                      Navigator.pushNamed(context, AppRoutes.rideHistory);
                    }),
                    _buildDrawerButton('Settings', () {
                      Scaffold.of(context).closeDrawer();
                      Navigator.pushNamed(context, AppRoutes.settings);
                    }),
                    _buildDrawerButton('Emergency', () {
                      Scaffold.of(context).closeDrawer();
                      Navigator.pushNamed(context, AppRoutes.emergency);
                    }),
                    _buildDrawerButton('Support', () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutes.support, (route) => false);
                    }),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Passenger',
                            style: AppTypography.labelText.copyWith(
                              fontWeight: FontWeight.w400,
                              color: loginResponse.user.modes.toLowerCase() ==
                                      'pessenger'
                                  ? AppColors.primaryColor
                                  : AppColors.primaryBlack,
                            ),
                          ),
                          Text(
                            'Driver',
                            style: AppTypography.labelText.copyWith(
                              fontWeight: FontWeight.w400,
                              color: loginResponse.user.modes.toLowerCase() ==
                                      'rider'
                                  ? AppColors.primaryColor
                                  : AppColors.primaryBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: CustomSwitch(
                        isActive: false,
                        switchValue:
                            loginResponse.user.modes.toLowerCase() == 'rider'
                                ? true
                                : false,
                        onChanged: (_) async {
                          final isChanged = await context
                              .read<AuthCubit>()
                              .changeMode(loginResponse.user.id.toString(),
                                  loginResponse.token);

                          if (!isChanged) {
                            return;
                          }
                          Navigator.pushNamedAndRemoveUntil(
                              context, AppRoutes.splash, (route) => false);
                        },
                      ),
                    ),
                    const SizedBox(height: 100), // Spacer for bottom section
                  ],
                ),
              ),
            ),
            // Bottom "Follow us" section
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color: AppColors.backgroundColor,
                child: Column(
                  children: [
                    Text(
                      'Follow us on',
                      style: AppTypography.paragraph,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      children: [
                        _buildSocialIcon(Assets.icons.facebook.path),
                        _buildSocialIcon(Assets.icons.instagram.path),
                        _buildSocialIcon(Assets.icons.linkedin.path),
                        _buildSocialIcon(Assets.icons.youtube.path),
                        _buildSocialIcon(Assets.icons.tiktok.path),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerButton(String text, VoidCallback onPressed) {
    return Column(
      children: [
        TextButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: AppTypography.labelText.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSocialIcon(String path) {
    return Image.asset(
      path,
      width: 25,
      height: 25,
      fit: BoxFit.contain,
    );
  }
}
