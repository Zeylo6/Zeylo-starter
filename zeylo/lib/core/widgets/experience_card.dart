import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'loading_shimmer.dart';

/// ExperienceCard widget displaying an experience with image, host info, and details
///
/// Features:
/// - Cover image with CachedNetworkImage and shimmer placeholder
/// - Heart/favorite icon in top-right corner (toggleable)
/// - Host name + avatar row below image
/// - Location text with pin icon
/// - Price text (right-aligned)
/// - Description preview with "See more" link
/// - Rating badge (if provided)
/// - Optional "98% Match" badge (for mood results)
/// - Card with rounded corners (16) and subtle shadow
/// - onTap callback
///
/// Example:
/// ```dart
/// ExperienceCard(
///   imageUrl: 'https://example.com/image.jpg',
///   hostName: 'John Doe',
///   hostAvatarUrl: 'https://example.com/avatar.jpg',
///   location: 'Colombo, Sri Lanka',
///   price: 'LKR 2,500',
///   description: 'Amazing experience...',
///   rating: 4.8,
///   ratingCount: 234,
///   isFavorite: false,
///   onTap: () => Navigator.push(...),
///   onFavoriteTap: () => toggleFavorite(),
/// )
/// ```
class ExperienceCard extends StatefulWidget {
  /// URL of the cover image
  final String imageUrl;

  /// Host name
  final String hostName;

  /// Host avatar URL
  final String? hostAvatarUrl;

  /// Location text
  final String location;

  /// Price text
  final String price;

  /// Description preview text
  final String description;

  /// Optional title for the experience
  final String? title;

  /// Rating value (1-5)
  final double? rating;

  /// Number of ratings
  final int? ratingCount;

  /// Whether the experience is favorited
  final bool isFavorite;

  /// Match percentage (e.g., "98% Match")
  final int? matchPercentage;

  /// Card height. Defaults to 300
  final double height;

  /// Card width. Defaults to full width
  final double? width;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when favorite icon is tapped
  final VoidCallback? onFavoriteTap;

  const ExperienceCard({
    required this.imageUrl,
    required this.hostName,
    required this.location,
    required this.price,
    required this.description,
    this.title,
    this.hostAvatarUrl,
    this.rating,
    this.ratingCount,
    this.isFavorite = false,
    this.matchPercentage,
    this.height = 320,
    this.width,
    this.onTap,
    this.onFavoriteTap,
    super.key,
  });

  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              color: AppColors.card,
              boxShadow: AppShadows.card,
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with favorite icon and match badge
                _buildImageSection(),
                // Content
                // Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title (if provided)
                      if (widget.title != null && widget.title!.isNotEmpty) ...[
                        Text(
                          widget.title!,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      // Host info
                      _buildHostInfo(),
                      const SizedBox(height: AppSpacing.sm),
                      // Location
                      _buildLocation(),
                      const SizedBox(height: AppSpacing.xs),
                      // Price
                      _buildPrice(),
                      const SizedBox(height: AppSpacing.sm),
                      // Description with See more
                      _buildDescription(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cover image
          CachedNetworkImage(
            imageUrl: widget.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const ShimmerListTile(),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surface,
              child: const Icon(Icons.image_not_supported),
            ),
          ),
          // Match badge (top-left)
          if (widget.matchPercentage != null)
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  '${widget.matchPercentage}% Match',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
              ),
            ),
          // Favorite icon (top-right)
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: GestureDetector(
              onTap: _toggleFavorite,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.textInverse.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? AppColors.error : AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostInfo() {
    return Row(
      children: [
        // Avatar
        if (widget.hostAvatarUrl != null)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: CachedNetworkImage(
                imageUrl: widget.hostAvatarUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: AppColors.surface),
                errorWidget: (context, url, error) =>
                    Container(color: AppColors.surface),
              ),
            ),
          )
        else
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE5E7EB),
            ),
          ),
        const SizedBox(width: AppSpacing.sm),
        // Host name
        Expanded(
          child: Text(
            widget.hostName,
            style: AppTypography.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Rating badge
        if (widget.rating != null && widget.ratingCount != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 14, color: Color(0xFFFDB022)),
                const SizedBox(width: 2),
                Text(
                  '${widget.rating}',
                  style: AppTypography.labelMedium,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.location,
            style: AppTypography.bodySmallSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return Text(
      widget.price,
      style: AppTypography.titleMedium.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.description,
          style: AppTypography.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'See more',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onFavoriteTap?.call();
  }
}
