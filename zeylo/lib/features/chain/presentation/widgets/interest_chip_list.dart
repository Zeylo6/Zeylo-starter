import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Interest chip list widget
///
/// Displays selectable interest chips for chain preferences:
/// - Food Tours
/// - Photography
/// - Walking Tours
/// - Nightlife
/// - Adventure
/// - Shopping
/// - Museums
/// - Nature
///
/// Example:
/// ```dart
/// InterestChipList(
///   selectedInterests: ['Food Tours', 'Photography'],
///   onInterestToggled: (interest) {
///     setState(() => toggleInterest(interest));
///   },
/// )
/// ```
class InterestChipList extends StatelessWidget {
  /// Currently selected interests
  final List<String> selectedInterests;

  /// Callback when an interest is toggled
  final ValueChanged<String> onInterestToggled;

  /// Available interests to display
  final List<String> interests;

  const InterestChipList({
    required this.selectedInterests,
    required this.onInterestToggled,
    this.interests = const [
      'Food Tours',
      'Photography',
      'Walking Tours',
      'Nightlife',
      'Adventure',
      'Shopping',
      'Museums',
      'Nature',
    ],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests',
          style: AppTypography.labelLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: interests.map((interest) {
            final isSelected = selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () => onInterestToggled(interest),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.surface,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInterestIcon(interest),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      interest,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestIcon(String interest) {
    IconData icon;
    switch (interest.toLowerCase()) {
      case 'food tours':
        icon = Icons.restaurant;
      case 'photography':
        icon = Icons.photo_camera;
      case 'walking tours':
        icon = Icons.directions_walk;
      case 'nightlife':
        icon = Icons.music_note;
      case 'adventure':
        icon = Icons.hiking;
      case 'shopping':
        icon = Icons.shopping_bag;
      case 'museums':
        icon = Icons.museum;
      case 'nature':
        icon = Icons.nature;
      default:
        icon = Icons.favorite;
    }

    return Icon(
      icon,
      color: selectedInterests.contains(interest)
          ? AppColors.primary
          : AppColors.textSecondary,
      size: 18,
    );
  }
}
