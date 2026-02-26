import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../domain/entities/post_entity.dart';

/// Community post card widget
///
/// Displays a large community post with:
/// - Full-width image with overlay text
/// - Post metadata below image
/// - Like, comment, and share buttons
class CommunityPostCard extends StatefulWidget {
  /// The post to display
  final Post post;

  /// Callback when like button is tapped
  final VoidCallback? onLikeTap;

  /// Callback when comment button is tapped
  final VoidCallback? onCommentTap;

  /// Callback when share button is tapped
  final VoidCallback? onShareTap;

  const CommunityPostCard({
    required this.post,
    this.onLikeTap,
    this.onCommentTap,
    this.onShareTap,
    super.key,
  });

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlay
          _buildImageSection(),

          // Post content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info row
                _buildUserInfo(),
                const SizedBox(height: AppSpacing.md),

                // Caption with tags
                _buildCaption(),
                const SizedBox(height: AppSpacing.md),

                // Timestamp
                Text(
                  _formatDate(widget.post.createdAt),
                  style: AppTypography.bodySmallSecondary,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Action buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    if (widget.post.images.isEmpty) {
      return SizedBox(
        height: 250,
        child: Container(
          color: AppColors.surface,
          child: const Center(
            child: Icon(Icons.image_not_supported),
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Image
        SizedBox(
          height: 250,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: widget.post.images.first,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const ShimmerListTile(height: 250),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surface,
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
        // Dark overlay
        Container(
          height: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: CachedNetworkImage(
              imageUrl: widget.post.userAvatar,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppColors.surface),
              errorWidget: (context, url, error) =>
                  Container(color: AppColors.surface),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Name
        Expanded(
          child: Text(
            widget.post.userName,
            style: AppTypography.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCaption() {
    // Parse caption and tags
    final parts = widget.post.caption.split(RegExp(r'#\w+'));
    final tags = RegExp(r'#\w+').allMatches(widget.post.caption).map((m) => m.group(0)!).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post.caption,
          style: AppTypography.bodyMedium,
        ),
        if (widget.post.tags.isNotEmpty || widget.post.experienceTag != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Wrap(
              spacing: AppSpacing.sm,
              children: [
                ...widget.post.tags.map(
                  (tag) => Text(
                    tag,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.post.experienceTag != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      widget.post.experienceTag!,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Like button
        _ActionButton(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          label: '${widget.post.likesCount}',
          iconColor: _isLiked ? AppColors.error : AppColors.textSecondary,
          onTap: () {
            setState(() {
              _isLiked = !_isLiked;
            });
            widget.onLikeTap?.call();
          },
        ),
        const SizedBox(width: AppSpacing.lg),

        // Comment button
        _ActionButton(
          icon: Icons.comment_outlined,
          label: '${widget.post.commentsCount}',
          onTap: widget.onCommentTap,
        ),
        const SizedBox(width: AppSpacing.lg),

        // Share button
        _ActionButton(
          icon: Icons.share_outlined,
          onTap: widget.onShareTap,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

/// Individual action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    this.label,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? AppColors.textSecondary,
            size: 20,
          ),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: AppTypography.bodySmall.copyWith(
                color: iconColor ?? AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
