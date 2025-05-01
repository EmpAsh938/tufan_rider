import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/network/api_endpoints.dart';
import 'package:tufan_rider/core/utils/text_utils.dart';
import 'package:tufan_rider/core/widgets/custom_switch.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/global_cubit/mode_cubit.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final currentMode = context.watch<ModeCubit>().state;

    final loginResponse = authCubit.loginResponse;
    return Drawer(
      backgroundColor: AppColors.backgroundColor,
      child: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 10.0,
                  bottom: 50.0, // Add bottom padding to avoid overlap
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Scaffold.of(context).closeDrawer();
                            Navigator.pushNamed(context, AppRoutes.profile);
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primaryColor,
                            backgroundImage: (loginResponse?.user.imageName !=
                                        null &&
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
                        ),
                        const SizedBox(width: 15),
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
                            if (currentMode == AppMode.rider)
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (currentMode == AppMode.rider) ...[
                      _buildDrawerButton('Internal Rides', () {
                        Scaffold.of(context).closeDrawer();
                        Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.map, (route) => false);
                      }),
                      // _buildDrawerButton('City to City', () {
                      //   Scaffold.of(context).closeDrawer();
                      //   Navigator.pushNamed(context, AppRoutes.rideHistory);
                      // }),
                      _buildDrawerButton('Tufan Credits', () {
                        Scaffold.of(context).closeDrawer();
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
                    _buildDrawerButton('Support', () {}),
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
                              color: currentMode == AppMode.passenger
                                  ? AppColors.primaryColor
                                  : AppColors.primaryBlack,
                            ),
                          ),
                          Text(
                            'Driver',
                            style: AppTypography.labelText.copyWith(
                              fontWeight: FontWeight.w400,
                              color: currentMode == AppMode.rider
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
                        switchValue: currentMode == AppMode.rider,
                        onChanged: (_) {
                          context.read<ModeCubit>().toggleMode();
                          Navigator.pushNamedAndRemoveUntil(
                              context, AppRoutes.map, (route) => false);
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
