import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/mystery_entity.dart';

/// Mystery experience type selector widget
///
/// Displays a 2x2 grid of experience type options:
/// - Adventure (mountain icon)
/// - Food & Drink (utensils icon)
/// - Arts & Culture (palette icon)
/// - Surprise Me (question icon)
///
/// Example:
/// ```dart
/// MysteryTypeSelector(
///   selectedType: MysteryExperienceType.adventure,
///   onTypeSelected: (type) {
///     setState(() => selectedType = type);
///   },
/// )
/// ```
class MysteryTypeSelector extends StatelessWidget {
  /// Currently selected experience type
  final MysteryExperienceType selectedType;

  /// Callback when an experience type is selected
  final ValueChanged<MysteryExperienceType> onTypeSelected;

  const MysteryTypeSelector({
    required this.selectedType,
    required this.onTypeSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience Type',
          style: AppTypography.labelLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: MysteryExperienceType.values.map((type) {
            return _buildTypeCard(type);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeCard(MysteryExperienceType type) {
    final isSelected = selectedType == type;

    return GestureDetector(
      onTap: () => onTypeSelected(type),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTypeIcon(type),
            const SizedBox(height: AppSpacing.sm),
            Text(
              type.label,
              textAlign: TextAlign.center,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(MysteryExperienceType type) {
    IconData iconData;
    switch (type) {
      case MysteryExperienceType.adventure:
        iconData = Icons.hiking;
      case MysteryExperienceType.foodAndDrink:
        iconData = Icons.restaurant;
      case MysteryExperienceType.artsAndCulture:
        iconData = Icons.palette;
      case MysteryExperienceType.surpriseMe:
        iconData = Icons.help_outline;
    }

    return Icon(
      iconData,
      color: selectedType == type ? AppColors.primary : AppColors.textSecondary,
      size: 32,
    );
  }
}
