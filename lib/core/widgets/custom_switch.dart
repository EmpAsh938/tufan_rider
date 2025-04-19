import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';

class CustomSwitch extends StatelessWidget {
  final ValueChanged<bool>? onChanged;
  final bool switchValue;
  final bool isActive;
  const CustomSwitch(
      {super.key,
      required this.onChanged,
      required this.switchValue,
      required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Switch(
      activeColor: AppColors.primaryColor,
      activeTrackColor: AppColors.gray,
      inactiveThumbColor: isActive ? AppColors.gray : AppColors.primaryColor,
      inactiveTrackColor: isActive ? AppColors.backgroundColor : AppColors.gray,
      trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (isActive) return AppColors.gray;
          return AppColors.neutralColor; // Track color when inactive
        },
      ),
      value: switchValue,
      // activeTrackColor: AppColors.gray,
      // activeColor: AppColors.neutralColor,
      // inactiveThumbColor: AppColors.neutralColor,
      onChanged: onChanged,
    );
  }
}
