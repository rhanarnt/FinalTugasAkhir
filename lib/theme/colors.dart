import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (from design system)
  static const Color primaryBrown = Color(0xFF8B6E58);
  static const Color primaryBrownDark = Color(0xFF6B5040);
  static const Color primaryBrownLight = Color(0xFFC4A882);

  // Secondary Colors
  static const Color secondaryBlue = Color(0xFF2196F3);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color secondaryOrange = Color(0xFFFF9800);
  static const Color secondaryRed = Color(0xFFF44336);

  // Status Colors
  static const Color statusSuccess = Color(0xFF4CAF50); // Tersedia (green)
  static const Color statusWarning = Color(0xFFFF9800); // Rendah (orange)
  static const Color statusError = Color(0xFFF44336); // Kritis (red)

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFFF5EFE8); // Primary BG
  static const Color grey200 = Color(0xFFE8DDD5); // Border
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9E8070); // Text Soft
  static const Color grey500 = Color(0xFF9E8070);
  static const Color grey600 = Color(0xFF6B5040); // Text Mid
  static const Color grey700 = Color(0xFF6B5040);
  static const Color grey800 = Color(0xFF2C1810); // Text Dark
  static const Color grey900 = Color(0xFF2C1810);

  // Background
  static const Color bgLight = Color(0xFFF5EFE8);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgGrey = Color(0xFFF5EFE8);

  // Text
  static const Color textPrimary = Color(0xFF2C1810);
  static const Color textSecondary = Color(0xFF6B5040);
  static const Color textTertiary = Color(0xFF9E8070);
  static const Color textLight = Color(0xFFF5EFE8);

  // Gradient (using primary brown)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBrown, primaryBrownDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Cream gradient for splash screen
  static const LinearGradient creamGradient = LinearGradient(
    colors: [Color(0xFFF5EFE8), Color(0xFFE8DDD5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow (with aliases for compatibility)
  static const BoxShadow lightShadow = BoxShadow(
    color: Color(0x19000000),
    blurRadius: 12,
    offset: Offset(0, 2),
  );
  static const BoxShadow shadowLight = lightShadow;

  static const BoxShadow mediumShadow = BoxShadow(
    color: Color(0x25000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
  static const BoxShadow shadowMedium = mediumShadow;

  static const BoxShadow heavyShadow = BoxShadow(
    color: Color(0x35000000),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  // Aliases for status colors
  static const Color successGreen = statusSuccess;
  static const Color warningYellow = statusWarning;
  static const Color errorRed = statusError;
}
