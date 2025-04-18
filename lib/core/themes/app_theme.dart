import 'package:flutter/material.dart';
import 'package:tufan_rider/core/constants/app_colors.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors
          .backgroundColor, // Set the background color for bottom sheet
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.primaryWhite,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.primaryBlack),
      bodyMedium: TextStyle(color: AppColors.neutralColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0),
      isDense: true,
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
      prefixStyle: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
            color: Colors.black), // Or use Theme.of(context).primaryColor
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryWhite,
      foregroundColor: AppColors.primaryBlack,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryBlack,
    scaffoldBackgroundColor: AppColors.primaryBlack,
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.primaryBlack,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryBlack,
      foregroundColor: AppColors.primaryWhite,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.primaryWhite),
      bodyMedium: TextStyle(color: AppColors.gray),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.gray,
      textTheme: ButtonTextTheme.primary,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryBlack,
      foregroundColor: AppColors.primaryWhite,
    ),
  );
}
