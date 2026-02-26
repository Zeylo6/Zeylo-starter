import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Photo grid widget displaying 3-column grid of photos
class PhotoGrid extends StatelessWidget {
  final List<String> photoUrls;
  final VoidCallback? onPhotoPressed;
  final int crossAxisCount;

  const PhotoGrid({
    required this.photoUrls,
    this.onPhotoPressed,
    this.crossAxisCount = 3,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrls.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text(
            'No posts yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
      ),
      itemCount: photoUrls.length,
      itemBuilder: (context, index) {
        return _PhotoTile(
          photoUrl: photoUrls[index],
          onPressed: onPhotoPressed,
        );
      },
    );
  }
}

/// Individual photo tile
class _PhotoTile extends StatelessWidget {
  final String photoUrl;
  final VoidCallback? onPressed;

  const _PhotoTile({
    required this.photoUrl,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: AppColors.surface,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: CachedNetworkImage(
            imageUrl: photoUrl,
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
              child: const Icon(Icons.error_outline),
            ),
          ),
        ),
      ),
    );
  }
}
