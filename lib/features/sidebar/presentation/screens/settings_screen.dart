import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/app/routes/app_route.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/cubit/theme/theme_cubit.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket.cubit.dart';
import 'package:tufan_rider/features/sidebar/presentation/screens/webview_screen.dart';
import 'package:tufan_rider/features/sidebar/presentation/widgets/sidebar_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        context.watch<ThemeCubit>().state.themeMode == ThemeMode.dark;

    return SidebarScaffold(
      title: 'Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phone Number
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.changePhone);
            },
            title: Text("Phone number"),
            subtitle: Text("98XXXXXXXX", style: TextStyle(color: Colors.grey)),
            trailing: Icon(Icons.arrow_forward_ios, size: 18),
          ),
          SizedBox(height: 10),

          // Language Selector
          Text("Language",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          DropdownButton<String>(
            dropdownColor: AppColors.backgroundColor,
            value: selectedLanguage,
            onChanged: (String? newValue) {
              setState(() {
                selectedLanguage = newValue!;
              });
            },
            // items: ["English", "Nepali", "Hindi"]
            items: ["English"].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 20),

          // Theme Toggle
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text("Theme",
          //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          //     Row(
          //       children: [
          //         Text("Light"),
          //         Switch(
          //           value: isDarkMode,
          //           activeColor: AppColors.primaryColor,
          //           activeTrackColor: AppColors.gray,
          //           inactiveThumbColor: AppColors.primaryColor,
          //           inactiveTrackColor: AppColors.gray,
          //           trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
          //             (states) {
          //               return AppColors
          //                   .neutralColor; // Track color when inactive
          //             },
          //           ),
          //           onChanged: (value) {
          //             context.read<ThemeCubit>().toggleTheme();
          //           },
          //         ),
          //         Text("Dark"),
          //       ],
          //     ),
          //   ],
          // ),
          // SizedBox(height: 20),

          // Other Settings
          buildClickableOption("Privacy policy", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebViewScreen(
                  url: 'https://mytufan.com/policy',
                  title: 'Privacy Policy',
                ),
              ),
            );
          }),
          buildClickableOption("Terms and conditions", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebViewScreen(
                  url: 'https://mytufan.com/terms-and-conditions',
                  title: 'Terms and conditions',
                ),
              ),
            );
          }),
          buildClickableOption(
              "Log out",
              () => showLogoutDialog(
                    context,
                    isDarkMode,
                  )),

          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget buildClickableOption(String title, [Function()? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  void showLogoutDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shadowColor:
              isDarkMode ? AppColors.backgroundColor : AppColors.primaryBlack,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          backgroundColor:
              isDarkMode ? AppColors.primaryBlack : AppColors.backgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                "Are you sure you want to log out?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.backgroundColor
                      : AppColors.primaryBlack,
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
                        color: isDarkMode
                            ? AppColors.backgroundColor
                            : AppColors.primaryBlack.withOpacity(0.4),
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
                      Navigator.pop(context); // Close dialog

                      // ✅ Clear all routes and push login screen
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );

                      locator.get<StompSocketCubit>().disconnect();

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
}
