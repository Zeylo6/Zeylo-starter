import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// How it works section for mystery feature
///
/// Displays 3 numbered steps explaining the mystery booking process:
/// 1. We'll find the perfect experience based on your preferences
/// 2. You'll receive the reveal 24 hours before your experience
/// 3. Show up and enjoy your surprise adventure!
///
/// Example:
/// ```dart
/// HowItWorksSection()
/// ```
class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  static const List<String> _steps = [
    "We'll find the perfect experience based on your preferences",
    "You'll receive the reveal 24 hours before your experience",
    "Show up and enjoy your surprise adventure!",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How it works:',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: List.generate(
            _steps.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildStep(index + 1, _steps[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep(int stepNumber, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number circle
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textInverse,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Step text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
