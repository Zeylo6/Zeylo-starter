import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../providers/community_provider.dart';
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
class CommunityPostCard extends ConsumerStatefulWidget {
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
  ConsumerState<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends ConsumerState<CommunityPostCard> {
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(deletePostProvider(widget.post.id).future);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete post: $e')),
          );
        }
      }
    }
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

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          height: 300,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.post.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.post.images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const ShimmerListTile(height: 300),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.image_not_supported),
                ),
              );
            },
          ),
        ),
        // Dark overlay
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Page Indicator
        if (widget.post.images.length > 1)
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${_currentPage + 1}/${widget.post.images.length}',
                  style: AppTypography.labelSmall.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo() {
    final currentUser = ref.watch(currentUserProvider).value;
    final isOwner = currentUser?.uid == widget.post.userId;
    final isAdmin = currentUser?.role == UserRole.admin;

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
        // More menu
        if (isOwner || isAdmin)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'delete') {
                _deletePost();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    SizedBox(width: 8),
                    Text('Delete Post', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
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
    super.key,
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
