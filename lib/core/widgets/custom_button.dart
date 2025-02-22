import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final String? imagePath;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor ?? AppColors.primaryWhite,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          if (imagePath != null) ...[
            Image.asset(
              imagePath!,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: AppTypography.actionText.copyWith(
              fontSize: 16,
              color: textColor ?? AppColors.primaryWhite,
            ),
          ),
        ],
      ),
    );
  }
}
