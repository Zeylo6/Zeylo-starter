import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'loading_shimmer.dart';

/// ExperienceCard widget displaying an experience with image, host info, and details
/// 2026 Modern Aesthetic: Soft surfaces, 24dp radius, elevated typography.
class ExperienceCard extends StatefulWidget {
  final String imageUrl;
  final String hostName;
  final String? hostAvatarUrl;
  final String location;
  final String price;
  final String description;
  final String? title;
  final bool isHostVerified;
  final double? rating;
  final int? ratingCount;
  final bool isFavorite;
  final int? matchPercentage;
  final double? height;
  final double? width;
  final String? heroTag;
  final VoidCallback? onTap;
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
    this.isHostVerified = false,
    this.height,
    this.width,
    this.heroTag,
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
    Widget cardContent = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.06), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerListTile(),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surface,
                        child: const Icon(Icons.image_not_supported, color: AppColors.textHint),
                      ),
                    ),
                    // Match Badge
                    if (widget.matchPercentage != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.matchPercentage}% Match',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Favorite Button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: _toggleFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
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
              ),
              // Content Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHostRow(),
                    const SizedBox(height: 12),
                    if (widget.title != null)
                      Text(
                        widget.title!,
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    _buildLocation(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPrice(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryExtraLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'View Details',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildHostRow() {
    return Row(
      children: [
        Stack(
          children: [
            if (widget.hostAvatarUrl != null)
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.divider,
                backgroundImage: CachedNetworkImageProvider(widget.hostAvatarUrl!),
              )
            else
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.divider,
                child: Icon(Icons.person, size: 16, color: AppColors.textHint),
              ),
            if (widget.isHostVerified)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified, color: AppColors.primary, size: 12),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.hostName,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.rating != null)
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Colors.orange),
              const SizedBox(width: 2),
              Text(
                widget.rating!.toStringAsFixed(1),
                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total price',
          style: AppTypography.labelSmall.copyWith(color: AppColors.textHint),
        ),
        Text(
          widget.price,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
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
