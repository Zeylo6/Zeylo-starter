import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// AI prompt enhancer card widget
///
/// Displays a toggle to enable AI enhancement of mood descriptions.
/// Shows the AI-enhanced version in a preview when enabled.
///
/// Example:
/// ```dart
/// AIEnhancerCard(
///   isEnabled: true,
///   onToggle: () => toggleAIEnhancer(),
///   originalText: 'I feel happy',
///   enhancedText: 'I feel happy and excited about trying new things',
/// )
/// ```
class AIEnhancerCard extends StatelessWidget {
  /// Whether AI enhancement is enabled
  final bool isEnabled;

  /// Callback when toggle is pressed
  final VoidCallback? onToggle;

  /// Original mood description
  final String originalText;

  /// AI-enhanced description
  final String enhancedText;

  const AIEnhancerCard({
    required this.isEnabled,
    required this.onToggle,
    required this.originalText,
    required this.enhancedText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Prompt Enhancer',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Let AI enhance your mood description for better matches',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Toggle switch
              Switch(
                value: isEnabled,
                onChanged: (_) => onToggle?.call(),
                activeColor: AppColors.primary,
                activeTrackColor:
                    AppColors.primary.withOpacity(0.3),
              ),
            ],
          ),

          // Enhanced preview section
          if (isEnabled && enhancedText.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enhanced Description',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    enhancedText,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
