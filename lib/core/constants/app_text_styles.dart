import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';

class AppTypography {
  static TextStyle placeholderText = GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.gray,
  );
  static TextStyle labelText = GoogleFonts.lexend(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryBlack,
  );
  static TextStyle smallText = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryBlack,
  );
  static TextStyle paragraph = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
  );
  static TextStyle subText = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
  );
  static TextStyle actionText = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryWhite,
  );

  static TextStyle headline = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryWhite,
  );
}
