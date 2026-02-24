import 'package:flutter/material.dart';

/// Application color palette
///
/// Defines all colors used throughout the Zeylo application including
/// primary brand colors, semantic colors (success, error, warning),
/// and neutral colors for text, backgrounds, and borders.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF8B5CF6); // Primary purple
  static const Color primaryLight = Color(0xFFA78BFA); // Light purple
  static const Color primaryDark = Color(0xFF7C3AED); // Dark purple
  static const Color secondary = Color(0xFF6D28D9); // Secondary purple

  // Background & Surfaces
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color surface = Color(0xFFF9FAFB); // Light gray surface
  static const Color card = Color(0xFFFFFFFF); // Card white background
  static const Color cardDark = Color(0xFF1E293B); // Dark card (for payment cards)

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937); // Dark gray text
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray text
  static const Color textHint = Color(0xFF9CA3AF); // Light gray text (hints)
  static const Color textInverse = Color(0xFFFFFFFF); // White text

  // Borders & Dividers
  static const Color border = Color(0xFFE5E7EB); // Light border
  static const Color divider = Color(0xFFF3F4F6); // Divider line

  // Semantic Colors
  static const Color success = Color(0xFF22C55E); // Green success
  static const Color successLight = Color(0xFFDCFCE7); // Light success background
  static const Color error = Color(0xFFEF4444); // Red error
  static const Color warning = Color(0xFFF59E0B); // Amber warning

  // Gradient Colors
  static const Color gradientStart = Color(0xFF8B5CF6); // Purple gradient start
  static const Color gradientEnd = Color(0xFFA855F7); // Pink-purple gradient end

  // Chat & Messaging
  static const Color chatBubbleSent = Color(0xFFC4B5FD); // Light purple sent bubble
  static const Color chatBubbleReceived = Color(0xFFF3F4F6); // Gray received bubble

  // Status Indicators
  static const Color onlineIndicator = Color(0xFF22C55E); // Green online status
  static const Color offlineIndicator = Color(0xFF9CA3AF); // Gray offline status

  // Overlay Colors
  static const Color scrim = Color(0x00000029); // Semi-transparent black for modals
  static const Color shadow = Color(0x1A000000); // Shadow color with transparency

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
