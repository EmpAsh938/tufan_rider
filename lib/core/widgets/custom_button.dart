import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final String? imagePath;
  final bool? isRounded;
  final bool isOutlined;
  final double? height;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.imagePath,
    this.isRounded,
    this.isOutlined = false,
    this.height,
    this.width,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: isOutlined ? _buildOutlinedButton() : _buildElevatedButton(),
    );
  }

  Widget _buildElevatedButton() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryColor,
        padding: padding ??
            EdgeInsets.symmetric(
              vertical: (height == null) ? 16 : 8,
              horizontal: 24,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              borderRadius ?? ((isRounded == null || !isRounded!) ? 8.0 : 0)),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: borderColor ?? (backgroundColor ?? AppColors.primaryColor),
          width: 1.5,
        ),
        backgroundColor: Colors.transparent,
        padding: padding ??
            EdgeInsets.symmetric(
              vertical: (height == null) ? 16 : 8,
              horizontal: 24,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              borderRadius ?? ((isRounded == null || !isRounded!) ? 8.0 : 0)),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: isOutlined
                ? (textColor ?? (backgroundColor ?? AppColors.primaryColor))
                : (textColor ?? AppColors.primaryWhite),
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
            color: isOutlined
                ? (textColor ?? (backgroundColor ?? AppColors.primaryColor))
                : (textColor ?? AppColors.primaryWhite),
          ),
        ),
      ],
    );
  }
}
