import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_switch.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
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

                    Navigator.pushNamed(context, '/profile');
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryColor,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'John Doe',
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

                  Navigator.pushNamed(context, '/ride_history');
                },
                child: Text(
                  'Ride',
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
                  'History',
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

                  Navigator.pushNamed(context, '/settings');
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

                  Navigator.pushNamed(context, '/emergency');
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
                      color: !isActive
                          ? AppColors.primaryColor
                          : AppColors.primaryBlack,
                    ),
                  ),
                  Text(
                    'Driver',
                    style: AppTypography.labelText.copyWith(
                      fontWeight: FontWeight.w400,
                      color: isActive
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
                switchValue: isActive,
                onChanged: (bool value) {
                  setState(() {
                    isActive = value;
                  });
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
