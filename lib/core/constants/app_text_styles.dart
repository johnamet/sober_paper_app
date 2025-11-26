import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTextStyles - Typography system for sacred journal aesthetic
/// Combines handwritten fonts for headings with readable serif for content
class AppTextStyles {
  // Display - Handwritten (for headings, emphasis)
  static TextStyle display1 = GoogleFonts.caveat(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBlack,
    height: 1.1,
    letterSpacing: 0.5,
  );
  
  static TextStyle display2 = GoogleFonts.caveat(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    color: AppColors.inkBlack,
    height: 1.2,
  );
  
  static TextStyle display3 = GoogleFonts.kalam(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.inkBlack,
    height: 1.3,
  );
  
  // Headings
  static TextStyle h1 = GoogleFonts.kalam(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.inkBlack,
    height: 1.3,
  );
  
  static TextStyle h2 = GoogleFonts.kalam(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.inkBrown,
    height: 1.4,
  );
  
  static TextStyle h3 = GoogleFonts.kalam(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.inkBrown,
    height: 1.4,
  );
  
  // Body - Readable serif (for content)
  static TextStyle bodyLarge = GoogleFonts.crimsonText(
    fontSize: 18,
    color: AppColors.inkBlack,
    height: 1.7,
    letterSpacing: 0.2,
  );
  
  static TextStyle bodyMedium = GoogleFonts.crimsonText(
    fontSize: 16,
    color: AppColors.inkBlack,
    height: 1.6,
    letterSpacing: 0.15,
  );
  
  static TextStyle bodySmall = GoogleFonts.crimsonText(
    fontSize: 14,
    color: AppColors.inkBrown,
    height: 1.5,
  );
  
  // Special Purpose
  static TextStyle prayer = GoogleFonts.crimsonText(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: AppColors.inkBrown,
    height: 1.8,
    letterSpacing: 0.3,
  );
  
  static TextStyle counter = GoogleFonts.kalam(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBlack,
    height: 1.0,
  );
  
  static TextStyle caption = GoogleFonts.crimsonText(
    fontSize: 12,
    color: AppColors.inkFaded,
    height: 1.4,
  );
  
  static TextStyle button = GoogleFonts.kalam(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.paperWhite,
    letterSpacing: 0.5,
  );
}
