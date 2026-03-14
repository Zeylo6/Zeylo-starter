import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Active experience tile widget
class ActiveExperienceTile extends StatelessWidget {
  final String experienceId;
  final String title;
  final String? thumbnailUrl;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  const ActiveExperienceTile({
    required this.experienceId,
    required this.title,
    this.thumbnailUrl,
    this.onEditPressed,
    this.onDeletePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.divider,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.divider,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_outlined, color: AppColors.textHint),
                    )
                  : const Icon(Icons.image_not_supported_outlined, color: AppColors.textHint),
            ),
          ),
          const SizedBox(width: 16),

          // Title and actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (onEditPressed != null)
                      GestureDetector(
                        onTap: onEditPressed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryExtraLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Edit Listing',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (onDeletePressed != null)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: AppColors.error.withOpacity(0.7)),
              onPressed: onDeletePressed,
            ),
        ],
      ),
    );
  }
}
