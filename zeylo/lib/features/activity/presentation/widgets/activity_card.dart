import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/activity_entity.dart';
import 'participants_row.dart';

/// Widget displaying an activity card for ongoing, upcoming, or past activities
class ActivityCard extends StatefulWidget {
  /// The activity to display
  final UserActivity activity;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when menu is tapped
  final VoidCallback? onMenuTap;

  /// Callback when view all participants is tapped
  final VoidCallback? onViewAllParticipants;

  const ActivityCard({
    required this.activity,
    this.onTap,
    this.onMenuTap,
    this.onViewAllParticipants,
    Key? key,
  }) : super(key: key);

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and menu
            _buildHeader(),
            const SizedBox(height: AppSpacing.lg),
            // Activity info based on status
            _buildActivityInfo(),
            const SizedBox(height: AppSpacing.lg),
            // Participants
            ParticipantsRow(
              participants: widget.activity.participants,
              label: _getParticipantsLabel(),
              onViewAll: widget.onViewAllParticipants,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.activity.experienceTitle,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: widget.onMenuTap,
          child: Icon(
            Icons.more_vert,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityInfo() {
    switch (widget.activity.status) {
      case ActivityStatus.ongoing:
        return _buildOngoingInfo();
      case ActivityStatus.upcoming:
        return _buildUpcomingInfo();
      case ActivityStatus.past:
        return _buildPastInfo();
    }
  }

  Widget _buildOngoingInfo() {
    final minutesLeft = widget.activity.durationMinutes - 50; // Mock: 50 mins passed
    return Row(
      children: [
        Icon(
          Icons.schedule,
          color: AppColors.textSecondary,
          size: 18,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$minutesLeft mins left',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingInfo() {
    final dateStr = _formatDate(widget.activity.startTime);
    final timeStr = _formatTime(widget.activity.startTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$dateStr, $timeStr',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${widget.activity.durationMinutes ~/ 60} hours • ${widget.activity.spotsLeft} spots left',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPastInfo() {
    final dateStr = _formatDateAgo(widget.activity.date);
    final timeStr = _formatTime(widget.activity.startTime);

    return Text(
      '$dateStr, $timeStr',
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _getParticipantsLabel() {
    switch (widget.activity.status) {
      case ActivityStatus.ongoing:
        return "WHO'S HERE (${widget.activity.participants.length})";
      case ActivityStatus.upcoming:
        return "WHO'S COMING (${widget.activity.participants.length})";
      case ActivityStatus.past:
        return "WHO'S CAME (${widget.activity.participants.length})";
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today';
    } else if (dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    }
    return 'Today';
  }
}
