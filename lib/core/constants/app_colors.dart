import 'package:flutter/material.dart';

class AppColors {
  // Primary Color Palette
  static const Color primaryColor = Color(0xFF00D4AA);
  static const Color primaryColorDark = Color(0xFF00A693);
  static const Color primaryColorLight = Color(0xFF4DFFDA);

  // Background Colors
  static const Color backgroundColor = Color(0xFF0A0F14);
  static const Color backgroundColorLight = Color(0xFF0D1117);

  // Surface Colors
  static const Color surfaceColor = Color(0xFF1C2128);
  static const Color cardColor = Color(0x0DFFFFFF); // 5% white opacity

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textTertiary = Color(0x80FFFFFF); // 50% white

  // Status Colors
  static const Color successColor = Color(0xFF00D4AA);
  static const Color errorColor = Color(0xFFFF4757);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF4FC3F7);

  // Category Colors
  static const Color healthColor = Color(0xFFFF4757);
  static const Color productivityColor = Color(0xFF4FC3F7);
  static const Color learningColor = Color(0xFF9C27B0);
  static const Color mindfulnessColor = Color(0xFFFF9800);
  static const Color creativeColor = Color(0xFF00D4AA);
  static const Color financeColor = Color(0xFF8BC34A);
  static const Color socialColor = Color(0xFFE91E63);

  // Border Colors
  static const Color borderColor = Color(0x1AFFFFFF); // 10% white
  static const Color borderColorLight = Color(0x0DFFFFFF); // 5% white

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, primaryColorDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundColor, backgroundColorLight, surfaceColor],
  );

  // Category gradient maps
  static const Map<String, Color> categoryColors = {
    'health': healthColor,
    'productivity': productivityColor,
    'learning': learningColor,
    'mindfulness': mindfulnessColor,
    'creative': creativeColor,
    'finance': financeColor,
    'social': socialColor,
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category.toLowerCase()] ?? primaryColor;
  }
}