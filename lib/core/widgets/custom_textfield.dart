import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';
import 'package:tufan_rider/core/constants/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color? suffixIconColor;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.suffixIconColor,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: AppTypography.labelText,
        ),
        const SizedBox(
          height: 8,
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            // hintText: hintText,
            hintStyle: AppTypography.placeholderText,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.gray,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.gray,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.gray,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            suffixIconColor: suffixIconColor,
          ),
        ),
      ],
    );
  }
}
