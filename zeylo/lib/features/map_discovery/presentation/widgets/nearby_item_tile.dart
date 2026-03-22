import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/map_provider.dart';

/// Glassmorphism nearby item tile
class NearbyItemTile extends StatelessWidget {
  final NearbyItem item;
  final VoidCallback? onTap;
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.55),
                  Colors.white.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: Colors.white.withOpacity(0.65),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(),
                const SizedBox(width: AppSpacing.lg),
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
                if (item.actionLabel != null) _buildActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    Color iconColor;
    switch (item.type) {
      case NearbyItemType.event:
        iconColor = AppColors.primary;
        break;
      case NearbyItemType.people:
        iconColor = const Color(0xFF22C55E);
        break;
      case NearbyItemType.business:
        iconColor = const Color(0xFF3B82F6);
        break;
    }

    final iconData = _getIconForType(item.type);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                iconColor.withOpacity(0.18),
                iconColor.withOpacity(0.08),
              ],
            ),
            border: Border.all(
              color: iconColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(iconData, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(NearbyItemType type) {
    switch (type) {
      case NearbyItemType.event:
        return Icons.event_rounded;
      case NearbyItemType.people:
        return Icons.people_rounded;
      case NearbyItemType.business:
        return Icons.location_on_rounded;
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: GestureDetector(
          onTap: onActionTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: isFilled
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.gradientEnd.withOpacity(0.65),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.55),
                        Colors.white.withOpacity(0.3),
                      ],
                    ),
              border: Border.all(
                color: isFilled
                    ? Colors.white.withOpacity(0.3)
                    : AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                if (isFilled)
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Text(
              item.actionLabel ?? 'Join',
              style: AppTypography.labelSmall.copyWith(
                color: isFilled ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
