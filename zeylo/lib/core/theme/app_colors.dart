import 'package:flutter/material.dart';

/// Application color palette
///
/// Defines all colors used throughout the Zeylo application including
/// primary brand colors, semantic colors (success, error, warning),
/// and neutral colors for text, backgrounds, and borders.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF8B5CF6); // Vibrant Purple
  static const Color primaryLight = Color(0xFFC4B5FD); // Light Purple
  static const Color primaryExtraLight = Color(0xFFF1F5F9); // Slate 100
  static const Color primaryDark = Color(0xFF6D28D9); // Dark Purple
  static const Color secondary = Color(0xFF7C3AED); // Secondary Purple
  static const Color primaryAlpha30 = Color(0x4D8B5CF6); // primary with 0.3 opacity

  // Background & Surfaces (Layered Strategy)
  // Stop using pure white. Use brand-tinted backgrounds for depth.
  static const Color background = Color(0xFFF9F7FF); // 2% Purple tint background
  static const Color surface = Color(0xFFFFFFFF); // Pure white for topmost elevation cards
  
  // Material 3 Surface Containers (Neutralized Slate for cleaner look)
  static const Color surfaceContainerLow = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceContainer = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceContainerHigh = Color(0xFFFFFFFF); // Pure White
  
  static const Color surfaceVariant = Color(0xFFF8FAFC); // Slate 50
  static const Color card = Color(0xFFFFFFFF); 
  static const Color cardDark = Color(0xFF1E293B);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textHint = Color(0xFF94A3B8); // Slate 400
  static const Color textInverse = Color(0xFFFFFFFF); // White text

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color divider = Color(0xFFF1F5F9); // Slate 100

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successLight = Color(0xFFD1FAE5); // Emerald 100
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500

  // Status Indicators
  static const Color onlineIndicator = Color(0xFF10B981);
  static const Color offlineIndicator = Color(0xFF94A3B8);

  // Chat & Messaging
  static const Color chatBubbleSent = Color(0xFFC4B5FD);
  static const Color chatBubbleReceived = Color(0xFFF1F5F9);

  // Gradient Colors
  static const Color gradientStart = Color(0xFF8B5CF6);
  static const Color gradientEnd = Color(0xFFD946EF); // Purple to Fuchsia

  // Overlay Colors
  static const Color scrim = Color(0x330F172A); // Semi-transparent Slate
  static const Color shadow = Color(0x0A0F172A); // Subtle depth

  /// Gradient from primary purple to accent purple
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient for disabled states
  static const LinearGradient disabledGradient = LinearGradient(
    colors: [Color(0xFFE5E7EB), Color(0xFFF3F4F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns a color with adjusted opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
