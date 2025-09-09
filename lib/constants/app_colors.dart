import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF000000);
  static const Color primaryLight = Color(0xFF424242);
  static const Color primaryDark = Color(0xFF000000);
  
  static const Color secondary = Colors.white;
  static const Color secondaryLight = Color(0xFFF8F8F8);
  static const Color secondaryDark = Color(0xFFE8E8E8);
  
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFC0C0C0);
  
  static const Color divider = Color(0xFFE8E8E8);
  static const Color shadow = Color(0x1A000000);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8F8F8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
