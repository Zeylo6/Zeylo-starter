import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Chat message bubble widget
class MessageBubble extends StatelessWidget {
  final String text;
  final DateTime timestamp;
  final bool isSent;

  const MessageBubble({
    required this.text,
    required this.timestamp,
    required this.isSent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSent
        ? AppColors.chatBubbleSent
        : AppColors.chatBubbleReceived;
    final textColor = isSent ? AppColors.textPrimary : AppColors.textPrimary;

    return Padding(
      padding: EdgeInsets.only(
        left: isSent ? AppSpacing.lg : AppSpacing.sm,
        right: isSent ? AppSpacing.sm : AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment:
            isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppRadius.md),
                topRight: const Radius.circular(AppRadius.md),
                bottomLeft: Radius.circular(
                  isSent ? AppRadius.md : 0,
                ),
                bottomRight: Radius.circular(
                  isSent ? 0 : AppRadius.md,
                ),
              ),
            ),
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatTime(timestamp),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
