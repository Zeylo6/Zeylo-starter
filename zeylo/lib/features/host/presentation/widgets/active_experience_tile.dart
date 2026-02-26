import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Active experience tile widget
class ActiveExperienceTile extends StatelessWidget {
  final String experienceId;
  final String title;
  final String? thumbnailUrl;
  final VoidCallback? onEditPressed;

  const ActiveExperienceTile({
    required this.experienceId,
    required this.title,
    this.thumbnailUrl,
    this.onEditPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: AppColors.surface,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surface,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surface,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    )
                  : Container(
                      color: AppColors.surface,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Title and edit link
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (onEditPressed != null)
                  GestureDetector(
                    onTap: onEditPressed,
                    child: Text(
                      'Edit',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
