import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Modern chat message bubble widget
class MessageBubble extends StatelessWidget {
  final String text;
  final DateTime timestamp;
  final bool isSent;
  final String messageType;
  final String? imageUrl;
  final bool isRead;

  const MessageBubble({
    required this.text,
    required this.timestamp,
    required this.isSent,
    this.messageType = 'text',
    this.imageUrl,
    this.isRead = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic styles based on sender
    final gradient = isSent
        ? const LinearGradient(
            colors: [AppColors.primary, Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;

    final bgColor = isSent ? null : AppColors.card;
    final textColor = isSent ? Colors.white : AppColors.textPrimary;

    return Padding(
      padding: EdgeInsets.only(
        left: isSent ? AppSpacing.xl : AppSpacing.md,
        right: isSent ? AppSpacing.md : AppSpacing.xl,
        bottom: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment:
            isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              gradient: gradient,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppRadius.lg),
                topRight: const Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(isSent ? AppRadius.lg : AppRadius.xs),
                bottomRight: Radius.circular(isSent ? AppRadius.xs : AppRadius.lg),
              ),
              boxShadow: isSent
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppRadius.lg),
                topRight: const Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(isSent ? AppRadius.lg : AppRadius.xs),
                bottomRight: Radius.circular(isSent ? AppRadius.xs : AppRadius.lg),
              ),
              child: _buildContent(textColor),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(
                _formatTime(timestamp),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              if (isSent) ...[
                const SizedBox(width: 4),
                Icon(
                  isRead ? Icons.done_all : Icons.check,
                  size: 14,
                  color: isRead ? AppColors.primary : AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    if (messageType == 'image' && imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        width: 200,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 200,
          height: 200,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          width: 200,
          height: 200,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        text,
        style: AppTypography.bodyMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    var hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }
}
