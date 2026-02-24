import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// MoodChip - Chip widget for mood categories, interest tags, and filters
///
/// Features:
/// - Icon + text in a rounded chip
/// - Selected/unselected states
/// - Purple border when selected
/// - Used for mood categories, interest tags, filter chips
/// - Optional leading icon
/// - Optional trailing icon
///
/// Example:
/// ```dart
/// MoodChip(
///   label: 'Adventure',
///   icon: Icons.hiking,
///   isSelected: true,
///   onTap: () => toggleMood('Adventure'),
/// )
/// ```
class MoodChip extends StatefulWidget {
  /// Chip label text
  final String label;

  /// Optional leading icon
  final IconData? icon;

  /// Whether the chip is selected
  final bool isSelected;

  /// Callback when chip is tapped
  final VoidCallback? onTap;

  /// Background color when unselected
  final Color unselectedBackgroundColor;

  /// Background color when selected
  final Color selectedBackgroundColor;

  /// Text color when unselected
  final Color unselectedTextColor;

  /// Text color when selected
  final Color selectedTextColor;

  /// Border color when unselected
  final Color unselectedBorderColor;

  /// Border color when selected
  final Color selectedBorderColor;

  /// Icon color when unselected
  final Color unselectedIconColor;

  /// Icon color when selected
  final Color selectedIconColor;

  /// Icon size
  final double iconSize;

  /// Padding
  final EdgeInsets padding;

  /// Border radius
  final double borderRadius;

  /// Border width
  final double borderWidth;

  /// Gap between icon and label
  final double iconGap;

  const MoodChip({
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.unselectedBackgroundColor = AppColors.surface,
    this.selectedBackgroundColor = AppColors.background,
    this.unselectedTextColor = AppColors.textPrimary,
    this.selectedTextColor = AppColors.primary,
    this.unselectedBorderColor = AppColors.border,
    this.selectedBorderColor = AppColors.primary,
    this.unselectedIconColor = AppColors.textSecondary,
    this.selectedIconColor = AppColors.primary,
    this.iconSize = 18,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    this.borderRadius = AppRadius.full,
    this.borderWidth = 1.5,
    this.iconGap = AppSpacing.sm,
    Key? key,
  }) : super(key: key);

  @override
  State<MoodChip> createState() => _MoodChipState();
}

class _MoodChipState extends State<MoodChip> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.isSelected ? widget.selectedBackgroundColor : widget.unselectedBackgroundColor;
    final textColor =
        widget.isSelected ? widget.selectedTextColor : widget.unselectedTextColor;
    final borderColor =
        widget.isSelected ? widget.selectedBorderColor : widget.unselectedBorderColor;
    final iconColor =
        widget.isSelected ? widget.selectedIconColor : widget.unselectedIconColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: borderColor,
              width: widget.borderWidth,
            ),
          ),
          padding: widget.padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: iconColor,
                ),
                SizedBox(width: widget.iconGap),
              ],
              Text(
                widget.label,
                style: AppTypography.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// SelectableMoodChip - Stateless version of MoodChip
/// Use this when you manage the selection state externally
class SelectableMoodChip extends StatelessWidget {
  /// Chip label text
  final String label;

  /// Optional leading icon
  final IconData? icon;

  /// Whether the chip is selected
  final bool isSelected;

  /// Callback when chip is tapped
  final VoidCallback? onTap;

  /// Background color when unselected
  final Color unselectedBackgroundColor;

  /// Background color when selected
  final Color selectedBackgroundColor;

  /// Padding
  final EdgeInsets padding;

  /// Icon size
  final double iconSize;

  /// Gap between icon and label
  final double iconGap;

  const SelectableMoodChip({
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.unselectedBackgroundColor = AppColors.surface,
    this.selectedBackgroundColor = AppColors.primary,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    this.iconSize = 18,
    this.iconGap = AppSpacing.sm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isSelected ? selectedBackgroundColor : unselectedBackgroundColor;
    final textColor =
        isSelected ? AppColors.textInverse : AppColors.textPrimary;
    final iconColor = isSelected ? AppColors.textInverse : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: isSelected
                ? null
                : Border.all(
                    color: AppColors.border,
                    width: 1.5,
                  ),
          ),
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
                SizedBox(width: iconGap),
              ],
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
