import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'loading_shimmer.dart';

/// ExperienceCard with full glassmorphism aesthetic
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
  final VoidCallback? onMessageTap;

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
    this.onMessageTap,
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
    Widget cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.6),
                Colors.white.withOpacity(0.35),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.65),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 40,
                offset: const Offset(0, 16),
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
                          placeholder: (context, url) =>
                              const ShimmerListTile(),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.image_not_supported,
                                color: AppColors.textHint),
                          ),
                        ),
                        // Gradient overlay at bottom of image
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.15),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Match Badge - glass style
                        if (widget.matchPercentage != null)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary.withOpacity(0.8),
                                        AppColors.gradientEnd
                                            .withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    '${widget.matchPercentage}% Match',
                                    style:
                                        AppTypography.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Favorite Button - glass style
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: _toggleFavorite,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.7),
                                        Colors.white.withOpacity(0.4),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.6),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      if (_isFavorite)
                                        BoxShadow(
                                          color: AppColors.error
                                              .withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: _isFavorite
                                        ? AppColors.error
                                        : AppColors.textPrimary,
                                    size: 20,
                                  ),
                                ),
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
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPrice(),
                            Row(
                              children: [
                                if (widget.onMessageTap != null)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(right: 8),
                                    child: _GlassButton(
                                      onTap: widget.onMessageTap!,
                                      icon:
                                          Icons.chat_bubble_outline_rounded,
                                      label: 'Message',
                                      isPrimary: false,
                                    ),
                                  ),
                                _GlassButton(
                                  onTap: widget.onTap ?? () {},
                                  label: 'View Details',
                                  isPrimary: true,
                                ),
                              ],
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
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.hostAvatarUrl != null
                  ? CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.divider,
                      backgroundImage: CachedNetworkImageProvider(
                          widget.hostAvatarUrl!),
                    )
                  : const CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.divider,
                      child: Icon(Icons.person,
                          size: 16, color: AppColors.textHint),
                    ),
            ),
            if (widget.isHostVerified)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.verified,
                      color: AppColors.primary, size: 12),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.2),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: Colors.orange),
                    const SizedBox(width: 2),
                    Text(
                      widget.rating!.toStringAsFixed(1),
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        Icon(Icons.location_on_rounded,
            size: 14,
            color: AppColors.primary.withOpacity(0.6)),
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
          style: AppTypography.labelSmall
              .copyWith(color: AppColors.textHint),
        ),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            widget.price,
            style: AppTypography.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
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

/// Glass-styled action button
class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData? icon;
  final String label;
  final bool isPrimary;

  const _GlassButton({
    required this.onTap,
    required this.label,
    required this.isPrimary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: isPrimary
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.gradientEnd.withOpacity(0.08),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.6),
                        Colors.white.withOpacity(0.35),
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPrimary
                    ? AppColors.primary.withOpacity(0.25)
                    : Colors.white.withOpacity(0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isPrimary
                      ? AppColors.primary.withOpacity(0.08)
                      : Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
