import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shadow definitions for Zeylo application
///
/// Provides consistent shadow presets for elevation effects on cards,
/// dialogs, and other elevated surfaces throughout the app.
class AppShadows {
  AppShadows._(); // Private constructor to prevent instantiation

  /// Small subtle shadow for slight elevation
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity black
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow for standard elevation
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity black
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Large shadow for prominent elevation
  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x26000000), // 15% opacity black
      blurRadius: 16,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// Card shadow - medium shadow suitable for cards
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity black
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Elevated card shadow - stronger shadow for interactive cards
  static const List<BoxShadow> elevatedCard = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity black
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Modal/Dialog shadow - deep shadow for overlays
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x33000000), // 20% opacity black
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: 0,
    ),
  ];

  /// Floating Action Button shadow
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x1F000000), // 12% opacity black
      blurRadius: 10,
      offset: Offset(0, 4),
      spreadRadius: 1,
    ),
  ];

  /// Input field shadow - subtle shadow for focus state
  static const List<BoxShadow> input = [
    BoxShadow(
      color: Color(0x08000000), // 3% opacity black
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Purple accent shadow (using primary color)
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Green success shadow
  static List<BoxShadow> successGlow = [
    BoxShadow(
      color: AppColors.success.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Red error shadow
  static List<BoxShadow> errorGlow = [
    BoxShadow(
      color: AppColors.error.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
}
