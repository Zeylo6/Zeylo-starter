import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Widget displaying a row of participant avatars with "View All" action
class ParticipantsRow extends StatelessWidget {
  /// List of participant avatar URLs
  final List<String> participants;

  /// Number of participants to display (rest will show as count)
  final int displayCount;

  /// Label text (e.g., "Who's here", "Who's coming")
  final String label;

  /// Callback when "View All" is tapped
  final VoidCallback? onViewAll;

  const ParticipantsRow({
    required this.participants,
    required this.label,
    this.displayCount = 4,
    this.onViewAll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View All >',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Avatar row
        SizedBox(
          height: 40,
          child: Stack(
            children: [
              for (int i = 0; i < (participants.length > displayCount ? displayCount : participants.length); i++)
                Positioned(
                  left: i * 28.0,
                  child: _buildAvatar(participants[i]),
                ),
              // Additional count if more than displayCount
              if (participants.length > displayCount)
                Positioned(
                  left: displayCount * 28.0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(
                        color: AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '+${participants.length - displayCount}',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String avatarUrl) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.background,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColors.surface,
          ),
          errorWidget: (context, url, error) => Container(
            color: Color(0xFFE5E7EB),
            child: const Icon(Icons.person, size: 20),
          ),
        ),
      ),
    );
  }
}
