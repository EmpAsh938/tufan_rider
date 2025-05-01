import 'package:flutter/material.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';
import 'package:tufan_rider/core/widgets/custom_button.dart';
import 'package:tufan_rider/core/widgets/custom_drawer.dart';
import 'package:tufan_rider/gen/assets.gen.dart';

class RiderRegistration extends StatelessWidget {
  const RiderRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image or graphic
                    Image.asset(
                      Assets.images.tufan.path, // Make sure this asset exists
                      height: 100,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 32),

                    // Informative text
                    Text(
                      "Not registered yet?",
                      style: AppTypography.labelText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Register button
                    CustomButton(
                      text: "Register here",
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.riderSignupFlow);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Drawer
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: EdgeInsets.all(1), // Adds space around the icon
                decoration: BoxDecoration(
                  color: AppColors.primaryWhite, // Background color
                  borderRadius: BorderRadius.circular(15), // Makes it circular
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlack
                          .withOpacity(0.1), // Optional shadow
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Builder(builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.primaryBlack,
                      size: 30,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      drawer: CustomDrawer(),
    );
  }
}
