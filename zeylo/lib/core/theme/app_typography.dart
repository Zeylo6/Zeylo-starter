import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography configuration for Zeylo application
///
/// Defines all text styles using Inter font family with consistent
/// sizing, weights, and colors throughout the application.
class AppTypography {
  AppTypography._(); // Private constructor to prevent instantiation

  static const String _fontFamily = 'Inter';

  // Display Styles (Large headings)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold, // 700
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold, // 700
    color: AppColors.textPrimary,
    height: 1.29,
    letterSpacing: -0.5,
  );

  // Headline Styles (Section headings)
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600, // Semibold
    color: AppColors.textPrimary,
    height: 1.33,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600, // Semibold
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600, // Semibold
    color: AppColors.textPrimary,
    height: 1.44,
    letterSpacing: 0.5,
  );

  // Title Styles (Smaller headings)
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600, // Semibold
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textPrimary,
    height: 1.57,
    letterSpacing: 0.1,
  );

  // Body Styles (Regular text)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal, // 400
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal, // 400
    color: AppColors.textPrimary,
    height: 1.57,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal, // 400
    color: AppColors.textPrimary,
    height: 1.67,
    letterSpacing: 0.4,
  );

  // Label Styles (Buttons, tags)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600, // Semibold
    color: AppColors.textPrimary,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textPrimary,
    height: 1.67,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.normal, // 400
    color: AppColors.textPrimary,
    height: 1.6,
    letterSpacing: 0.5,
  );

  // Caption Style (Small text, secondary information)
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.normal, // 400
    color: AppColors.textSecondary,
    height: 1.45,
    letterSpacing: 0.5,
  );

  /// Variants with secondary text color
  static const TextStyle bodyMediumSecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal, // 400
    color: AppColors.textSecondary,
    height: 1.57,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmallSecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal, // 400
    color: AppColors.textSecondary,
    height: 1.67,
    letterSpacing: 0.4,
  );

  /// Variants with hint text color
  static const TextStyle bodySmallHint = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal, // 400
    color: AppColors.textHint,
    height: 1.67,
    letterSpacing: 0.4,
  );

  /// Create a text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}
