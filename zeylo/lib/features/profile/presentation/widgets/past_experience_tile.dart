import 'package:flutter/material.dart';
import 'package:zeylo/core/theme/app_colors.dart';
import 'package:zeylo/core/theme/app_radius.dart';
import 'package:zeylo/core/theme/app_spacing.dart';
import 'package:zeylo/core/theme/app_typography.dart';

class PastExperienceTile extends StatelessWidget {
  final String experienceId;
  final String title;
  final double rating;
  final int ratingCount;
  final double price;

  const PastExperienceTile({
    required this.experienceId,
    required this.title,
    required this.rating,
    required this.ratingCount,
    required this.price,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
<<<<<<< HEAD
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon or Thumbnail Placeholder
          Container(
            width: 48,
            height: 48,
=======
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
>>>>>>> 9b34c0d95a1df91e0c497255d53a922e51e90083
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
<<<<<<< HEAD
            child: const Icon(
              Icons.history_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          
          // Info
=======
            child: const Icon(Icons.history, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
>>>>>>> 9b34c0d95a1df91e0c497255d53a922e51e90083
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
<<<<<<< HEAD
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
=======
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
>>>>>>> 9b34c0d95a1df91e0c497255d53a922e51e90083
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
<<<<<<< HEAD
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
=======
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: AppTypography.labelSmall,
>>>>>>> 9b34c0d95a1df91e0c497255d53a922e51e90083
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($ratingCount)',
<<<<<<< HEAD
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
=======
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
>>>>>>> 9b34c0d95a1df91e0c497255d53a922e51e90083
                    ),
                  ],
                ),
              ],
            ),
          ),
<<<<<<< HEAD
          
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'LKR ${price.toStringAsFixed(0)}',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
=======
          Text(
            '\$$price',
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
>>>>>>> 9b34c0d95a1df91e0c497255d53a922e51e90083
          ),
        ],
      ),
    );
  }
}
