import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// EmptyStateWidget - Display for empty data states
///
/// Features:
/// - Large illustration/icon area
/// - Title text
/// - Subtitle text
/// - Optional action button
/// - Used for empty favorites, no results, etc.
///
/// Example:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.favorite_outline,
///   title: 'No Favorites Yet',
///   subtitle: 'Start adding experiences to your favorites',
///   actionLabel: 'Explore Experiences',
///   onAction: () => Navigator.push(...),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Icon color
  final Color iconColor;

  /// Icon size
  final double iconSize;

  /// Title text
  final String title;

  /// Subtitle text
  final String subtitle;

  /// Optional action button label
  final String? actionLabel;

  /// Callback for action button
  final VoidCallback? onAction;

  /// Whether to center the content
  final bool centered;

  /// Padding
  final EdgeInsets padding;

  /// Background color
  final Color? backgroundColor;

  const EmptyStateWidget({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = AppColors.textSecondary,
    this.iconSize = 80,
    this.actionLabel,
    this.onAction,
    this.centered = true,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
        const SizedBox(height: AppSpacing.xl),
        // Title
        Text(
          title,
          style: AppTypography.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        // Subtitle
        Text(
          subtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        // Action button
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Center(
                    child: Text(
                      actionLabel!,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );

    if (centered) {
      return Container(
        color: backgroundColor,
        child: Center(
          child: Padding(
            padding: padding,
            child: content,
          ),
        ),
      );
    }

    return Container(
      color: backgroundColor,
      child: Padding(
        padding: padding,
        child: content,
      ),
    );
  }
}

/// EmptyFavoritesWidget - Specific variant for empty favorites
class EmptyFavoritesWidget extends StatelessWidget {
  /// Callback for explore button
  final VoidCallback? onExplore;

  /// Whether to center the content
  final bool centered;

  const EmptyFavoritesWidget({
    this.onExplore,
    this.centered = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.favorite_outline,
      title: 'No Favorites Yet',
      subtitle: 'Start adding experiences to your favorites',
      actionLabel: onExplore != null ? 'Explore Experiences' : null,
      onAction: onExplore,
      centered: centered,
    );
  }
}

/// EmptySearchResultsWidget - Specific variant for no search results
class EmptySearchResultsWidget extends StatelessWidget {
  /// Search query
  final String searchQuery;

  /// Callback for clear search
  final VoidCallback? onClearSearch;

  /// Whether to center the content
  final bool centered;

  const EmptySearchResultsWidget({
    required this.searchQuery,
    this.onClearSearch,
    this.centered = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off_outlined,
      title: 'No Results Found',
      subtitle: 'No experiences match "$searchQuery". Try a different search.',
      actionLabel: onClearSearch != null ? 'Clear Search' : null,
      onAction: onClearSearch,
      centered: centered,
    );
  }
}

/// EmptyNotificationsWidget - Specific variant for no notifications
class EmptyNotificationsWidget extends StatelessWidget {
  /// Whether to center the content
  final bool centered;

  const EmptyNotificationsWidget({
    this.centered = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.notifications_none_outlined,
      title: 'No Notifications',
      subtitle: 'You\'re all caught up! Check back later for updates.',
      centered: centered,
    );
  }
}

/// EmptyChatsWidget - Specific variant for no chats
class EmptyChatsWidget extends StatelessWidget {
  /// Callback for browse button
  final VoidCallback? onBrowse;

  /// Whether to center the content
  final bool centered;

  const EmptyChatsWidget({
    this.onBrowse,
    this.centered = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.mail_outline,
      title: 'No Messages Yet',
      subtitle: 'Start conversations with hosts by booking experiences',
      actionLabel: onBrowse != null ? 'Browse Experiences' : null,
      onAction: onBrowse,
      centered: centered,
    );
  }
}
