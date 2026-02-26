import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// SectionHeader - Header for content sections
///
/// Features:
/// - Title text (bold) on left
/// - Optional "See all" or action text on right
/// - Optional icon
/// - Customizable padding
///
/// Example:
/// ```dart
/// SectionHeader(
///   title: 'Popular Experiences',
///   actionText: 'See all',
///   onActionTap: () => Navigator.push(...),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  /// Title text
  final String title;

  /// Optional action text (e.g., "See all", "View all")
  final String? actionText;

  /// Callback for action text tap
  final VoidCallback? onActionTap;

  /// Optional icon on the left of title
  final IconData? icon;

  /// Icon color
  final Color iconColor;

  /// Icon size
  final double iconSize;

  /// Padding around the header
  final EdgeInsets padding;

  /// Gap between icon and title
  final double iconGap;

  /// Text alignment
  final MainAxisAlignment mainAxisAlignment;

  const SectionHeader({
    required this.title,
    this.actionText,
    this.onActionTap,
    this.icon,
    this.iconColor = AppColors.textSecondary,
    this.iconSize = 20,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    this.iconGap = AppSpacing.sm,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          // Left side with icon and title
          Expanded(
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: iconSize,
                    color: iconColor,
                  ),
                  SizedBox(width: iconGap),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Right side with action text
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// SectionHeaderWithIcon - Section header with icon variants
class SectionHeaderWithIcon extends StatelessWidget {
  /// Title text
  final String title;

  /// Icon data
  final IconData icon;

  /// Icon color
  final Color iconColor;

  /// Icon size
  final double iconSize;

  /// Optional action text
  final String? actionText;

  /// Callback for action text tap
  final VoidCallback? onActionTap;

  /// Padding
  final EdgeInsets padding;

  const SectionHeaderWithIcon({
    required this.title,
    required this.icon,
    this.iconColor = AppColors.textSecondary,
    this.iconSize = 20,
    this.actionText,
    this.onActionTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      title: title,
      icon: icon,
      iconColor: iconColor,
      iconSize: iconSize,
      actionText: actionText,
      onActionTap: onActionTap,
      padding: padding,
    );
  }
}
