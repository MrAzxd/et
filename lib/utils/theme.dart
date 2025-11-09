import 'package:e/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static ThemeData theme = ThemeData(
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
    ),
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: kBackgroundColor,
    colorScheme: const ColorScheme.light(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      surface: kBackgroundColor,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: kTextColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: kTextColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        color: kTextColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        color: kTextColorSecondary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.sp, horizontal: 24.sp),
        textStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor:
          Colors.green.withValues(alpha: 0.9), // Use gradient instead
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6.0,
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      actionTextColor: Color(0xFF66BB6A), // Medium green for action text
      // Custom gradient background
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: kTextColorSecondary),
      hintStyle: const TextStyle(color: kTextColorSecondary),
    ),
    useMaterial3: true,
  );
}
