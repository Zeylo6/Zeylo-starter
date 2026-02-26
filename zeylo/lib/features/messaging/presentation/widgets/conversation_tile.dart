import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/host_avatar.dart';

/// Conversation tile widget for contact list
class ConversationTile extends StatelessWidget {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isOnline;
  final VoidCallback? onPressed;

  const ConversationTile({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.isOnline = false,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Avatar
            HostAvatar(
              imageUrl: userPhotoUrl,
              hostName: userName,
              size: AvatarSize.medium,
              isOnline: isOnline,
            ),
            const SizedBox(width: AppSpacing.md),

            // Name and last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userName,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (lastMessage != null)
                    Text(
                      lastMessage!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),

            // Last message time
            if (lastMessageTime != null)
              Text(
                _formatTime(lastMessageTime!),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Same day - show time
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } else {
      // Older - show date
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
