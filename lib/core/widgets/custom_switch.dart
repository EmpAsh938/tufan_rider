import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';

class CustomSwitch extends StatelessWidget {
  final ValueChanged<bool>? onChanged;
  final bool switchValue;
  const CustomSwitch(
      {super.key, required this.onChanged, required this.switchValue});

  @override
  Widget build(BuildContext context) {
    return Switch(
      activeColor: AppColors.primaryColor,
      activeTrackColor: AppColors.gray,
      inactiveThumbColor: AppColors.primaryColor,
      inactiveTrackColor: AppColors.gray,
      trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
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
