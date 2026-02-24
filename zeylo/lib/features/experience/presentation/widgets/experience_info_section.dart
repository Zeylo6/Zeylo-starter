import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Widget displaying information sections like "What's Included" and "Requirements"
///
/// Shows:
/// - Section title
/// - Bullet list of items
class ExperienceInfoSection extends StatelessWidget {
  /// Section title
  final String title;

  /// List of items to display
  final List<String> items;

  const ExperienceInfoSection({
    required this.title,
    required this.items,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          title,
          style: AppTypography.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        // Items list
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bullet point
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.xs,
                          right: AppSpacing.md,
                        ),
                        child: Text(
                          '•',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      // Item text
                      Expanded(
                        child: Text(
                          item,
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
