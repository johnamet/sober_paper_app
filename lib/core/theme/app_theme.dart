import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  static ThemeData journalTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.paperCream,
    
    colorScheme: ColorScheme.light(
      primary: AppColors.holyBlue,
      secondary: AppColors.crossGold,
      error: AppColors.panicRed,
      surface: AppColors.paperWhite,
    ),
    
    textTheme: TextTheme(
      displayLarge: AppTextStyles.display1,
      displayMedium: AppTextStyles.display2,
      headlineMedium: AppTextStyles.h1,
      headlineSmall: AppTextStyles.h2,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
    ),
    
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.inkBrown),
      titleTextStyle: AppTextStyles.h2,
    ),
    
    cardTheme: CardThemeData(
      color: AppColors.paperWhite,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.paperEdge, width: 1),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.holyBlue,
        foregroundColor: AppColors.paperWhite,
        textStyle: AppTextStyles.button,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.paperWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.paperEdge),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.paperEdge),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.holyBlue, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
