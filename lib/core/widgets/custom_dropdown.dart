import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';

class CustomDropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String labelText;
  final String? hintText;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.labelText,
    this.hintText,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor:
          AppColors.backgroundColor, // Use your custom background color
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(
          color: AppColors.primaryBlack.withOpacity(0.6), // Custom label color
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: AppColors.primaryGreen, // Custom hint text color
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.gray), // Custom border color
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.gray),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.gray),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      items: items.map((branch) {
        return DropdownMenuItem(
          value: branch,
          child: Text(
            branch,
            style: TextStyle(
              color: AppColors.primaryBlack
                  .withOpacity(0.6), // Custom text color for dropdown items
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
