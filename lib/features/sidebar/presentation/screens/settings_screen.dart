import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/cubit/theme/theme_cubit.dart';
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
            items: ["English", "Nepali", "Hindi"]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 20),

          // Theme Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Theme",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text("Light"),
                  Switch(
                    value: isDarkMode,
                    activeColor: AppColors.primaryColor,
                    activeTrackColor: AppColors.gray,
                    inactiveThumbColor: AppColors.primaryColor,
                    inactiveTrackColor: AppColors.gray,
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
                      (states) {
                        return AppColors
                            .neutralColor; // Track color when inactive
                      },
                    ),
                    onChanged: (value) {
                      // context.read<ThemeCubit>().toggleTheme();
                    },
                  ),
                  Text("Dark"),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),

          // Other Settings
          buildClickableOption("Privacy policy"),
          buildClickableOption("Terms and conditions"),
          buildClickableOption("Log out", () => showLogoutDialog(context)),

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
        child: Text(title, style: TextStyle(fontSize: 16, color: Colors.black)),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Are you sure about logging out?",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("No", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Handle logout logic here
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: Text("Yes", style: TextStyle(color: Colors.white)),
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
