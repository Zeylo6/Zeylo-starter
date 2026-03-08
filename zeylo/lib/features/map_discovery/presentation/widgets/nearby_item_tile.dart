import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/map_provider.dart';

/// Widget displaying a single nearby item in the list
class NearbyItemTile extends StatelessWidget {
  /// The nearby item
  final NearbyItem item;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when action button is tapped
  final VoidCallback? onActionTap;

  const NearbyItemTile({
    required this.item,
    this.onTap,
    this.onActionTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            _buildIcon(),
            const SizedBox(width: AppSpacing.lg),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetails(),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Action button
            if (item.actionLabel != null)
              _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    Color iconColor = AppColors.primary;

    switch (item.type) {
      case NearbyItemType.event:
        iconColor = AppColors.primary; // Purple
        break;
      case NearbyItemType.people:
        iconColor = const Color(0xFF22C55E); // Green
        break;
      case NearbyItemType.business:
        iconColor = const Color(0xFF3B82F6); // Blue
        break;
    }

    final iconData = _getIconForType(item.type);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }

  IconData _getIconForType(NearbyItemType type) {
    switch (type) {
      case NearbyItemType.event:
        return Icons.event;
      case NearbyItemType.people:
        return Icons.people;
      case NearbyItemType.business:
        return Icons.location_on;
    }
  }

  Widget _buildDetails() {
    final details = <String>[];

    if (item.distance != null) details.add(item.distance!);
    if (item.time != null) details.add(item.time!);
    if (item.rating != null) details.add(item.rating!);
    if (item.details != null) details.add(item.details!);
    if (item.commuteFromPreviousMinutes != null) {
      details.insert(
        0,
        '${item.commuteFromPreviousMinutes} min from previous',
      );
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Text(
      details.join(' • '),
      style: AppTypography.labelSmall.copyWith(
        color: AppColors.textSecondary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButton() {
    final isFilled = item.type == NearbyItemType.event;

    return SizedBox(
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onActionTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isFilled ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: AppColors.primary,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Text(
                item.actionLabel ?? 'Join',
                style: AppTypography.labelSmall.copyWith(
                  color: isFilled ? AppColors.textInverse : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
