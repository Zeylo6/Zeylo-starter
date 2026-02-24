import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Individual mood card widget
///
/// Displays a mood option with icon and label in a selectable card.
/// Used in mood selector grid.
///
/// Example:
/// ```dart
/// MoodCard(
///   icon: Icons.sentiment_satisfied,
///   label: 'Happy',
///   isSelected: true,
///   onTap: () => selectMood('Happy'),
/// )
/// ```
class MoodCard extends StatelessWidget {
  /// Icon to display for the mood
  final IconData icon;

  /// Mood label text
  final String label;

  /// Whether this mood is currently selected
  final bool isSelected;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Card background color when unselected
  final Color unselectedColor;

  /// Card background color when selected
  final Color selectedColor;

  const MoodCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.unselectedColor = AppColors.surface,
    this.selectedColor = const Color(0xFFF3E8FF),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 40,
            ),
            const SizedBox(height: AppSpacing.md),
            // Label
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.labelMedium.copyWith(
                color:
                    isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
