import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/host_provider.dart';
import '../widgets/active_experience_tile.dart';
import '../widgets/host_stats_header.dart';
import '../widgets/performance_section.dart';

/// Host dashboard screen
class HostDashboardScreen extends ConsumerWidget {
  final String hostId;
  final String hostName;
  final String? hostPhotoUrl;
  final bool isSuperhost;

  const HostDashboardScreen({
    required this.hostId,
    required this.hostName,
    this.hostPhotoUrl,
    this.isSuperhost = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(hostStatsProvider(hostId));
    final thisMonthAsync = ref.watch(thisMonthEarningsProvider(hostId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: statsAsync.when(
        data: (stats) => thisMonthAsync.when(
          data: (thisMonth) => _buildContent(
            context,
            stats,
            thisMonth,
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    dynamic stats,
    double thisMonth,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          HostStatsHeader(
            hostName: hostName,
            hostPhotoUrl: hostPhotoUrl,
            isSuperhost: isSuperhost,
            thisMonthEarnings: thisMonth,
            averageRating: stats.averageRating,
            stats: stats,
          ),

          const SizedBox(height: AppSpacing.md),

          // Profile completion section
          _buildProfileCompletionSection(context, stats.profileCompletion),

          const SizedBox(height: AppSpacing.md),

          // Performance section
          PerformanceSection(
            responseRate: stats.responseRate,
            acceptanceRate: stats.acceptanceRate,
            totalBookings: stats.totalBookings,
          ),

          const SizedBox(height: AppSpacing.md),

          // Active experiences section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Experiences',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Experience list
                ActiveExperienceTile(
                  experienceId: '1',
                  title: 'Surfing in Weligama',
                  onEditPressed: () {},
                ),
                ActiveExperienceTile(
                  experienceId: '2',
                  title: 'Sunrise watching',
                  onEditPressed: () {},
                ),
                ActiveExperienceTile(
                  experienceId: '3',
                  title: 'Traditional Cooking',
                  onEditPressed: () {},
                ),

                const SizedBox(height: AppSpacing.md),

                // Create new experience link
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Create New Experience',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionSection(BuildContext context, int completion) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completion',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completion%',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: completion / 100,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Completion message
          Text(
            'Add 2 more photos to reach 100%',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
