import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                    backgroundImage: (loginResponse?.user.imageName != null &&
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
                SizedBox(
                  width: 20,
                ),
                Text(
                  loginResponse == null
                      ? ''
                      : TextUtils.capitalizeEachWord(loginResponse.user.name),
                  style: AppTypography.labelText.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: () {
                  Scaffold.of(context).closeDrawer();

                  Navigator.pushNamed(context, AppRoutes.rideHistory);
                },
                child: Text(
                  'Ride History',
                  style: AppTypography.labelText.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                )),
            SizedBox(
              height: 20,
            ),
            // TextButton(
            //     onPressed: () {},
            //     child: Text(
            //       'History',
            //       style: AppTypography.labelText.copyWith(
            //         fontWeight: FontWeight.w400,
            //       ),
            //     )),
            // SizedBox(
            //   height: 20,
            // ),
            TextButton(
                onPressed: () {
                  Scaffold.of(context).closeDrawer();

                  Navigator.pushNamed(context, AppRoutes.settings);
                },
                child: Text(
                  'Settings',
                  style: AppTypography.labelText.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                )),
            SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: () {
                  Scaffold.of(context).closeDrawer();

                  Navigator.pushNamed(context, AppRoutes.emergency);
                },
                child: Text(
                  'Emergency',
                  style: AppTypography.labelText.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                )),
            SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: () {},
                child: Text(
                  'Support',
                  style: AppTypography.labelText.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                )),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
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
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Follow us on',
                  style: AppTypography.paragraph,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    Image.asset(
                      Assets.icons.facebook.path,
                      width: 25,
                      height: 25,
                      fit: BoxFit.contain,
                    ),
                    Image.asset(
                      Assets.icons.instagram.path,
                      width: 25,
                      height: 25,
                      fit: BoxFit.contain,
                    ),
                    Image.asset(
                      Assets.icons.linkedin.path,
                      width: 25,
                      height: 25,
                      fit: BoxFit.contain,
                    ),
                    Image.asset(
                      Assets.icons.youtube.path,
                      width: 25,
                      height: 25,
                      fit: BoxFit.contain,
                    ),
                    Image.asset(
                      Assets.icons.tiktok.path,
                      width: 25,
                      height: 25,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      )),
    );
  }
}
