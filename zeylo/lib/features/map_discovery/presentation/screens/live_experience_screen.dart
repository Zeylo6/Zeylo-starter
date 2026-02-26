import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Screen for an ongoing/live experience
class LiveExperienceScreen extends StatefulWidget {
  /// Experience ID
  final String experienceId;

  /// Experience title
  final String? title;

  /// Participant avatars
  final List<String>? participants;

  const LiveExperienceScreen({
    required this.experienceId,
    this.title = 'Sunset Kayaking',
    this.participants,
    super.key,
  });

  @override
  State<LiveExperienceScreen> createState() => _LiveExperienceScreenState();
}

class _LiveExperienceScreenState extends State<LiveExperienceScreen> {
  // Track elapsed time (mock)
  late Duration elapsedTime;

  @override
  void initState() {
    super.initState();
    elapsedTime = const Duration(hours: 2, minutes: 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Full map view
          _buildMapView(),
          // Back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textPrimary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom sheet
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      color: const Color(0xFFF0F4FF),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Map background
          Container(
            color: const Color(0xFFF0F4FF),
            child: Center(
              child: Icon(
                Icons.map,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
            ),
          ),
          // Location pin (center)
          Center(
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Title
            Text(
              widget.title ?? 'Experience',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Status and elapsed time
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Ongoing • ${_formatDuration(elapsedTime)} elapsed',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Participants
            Row(
              children: [
                // Avatar stack
                SizedBox(
                  height: 40,
                  width: 140,
                  child: Stack(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Positioned(
                          left: i * 28.0,
                          child: _buildParticipantAvatar(
                            'avatar_$i',
                          ),
                        ),
                      Positioned(
                        left: 84.0,
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
                              '+2',
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
            ),
            const SizedBox(height: AppSpacing.xl),
            // End Experience button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Handle end experience
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('End Experience?'),
                        content: const Text(
                          'Are you sure you want to end this experience?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'End',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'End Experience',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantAvatar(String avatarUrl) {
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
