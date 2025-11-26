import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppShadows - Paper-like shadow effects
class AppShadows {
  // Soft paper shadow
  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.paperShadow,
      blurRadius: 8,
      offset: const Offset(2, 4),
    ),
  ];
  
  // Elevated paper
  static List<BoxShadow> elevated = [
    BoxShadow(
      color: AppColors.paperShadow,
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
  
  // Floating element
  static List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.paperShadow.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
