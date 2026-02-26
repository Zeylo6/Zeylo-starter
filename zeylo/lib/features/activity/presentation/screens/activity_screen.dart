import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/activity_provider.dart';
import '../widgets/activity_card.dart';
import '../widgets/mystery_countdown_card.dart';

/// Screen displaying user's activities (ongoing, upcoming, past)
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    // Load activities on screen initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activityProvider.notifier).loadActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Tab bar
          _buildTabBar(state),
          // Content
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Text('Error: ${state.error}'),
                      )
                    : _buildContent(state),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: AppColors.textPrimary,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'My Activity',
        style: AppTypography.headlineSmall,
      ),
      centerTitle: false,
    );
  }

  Widget _buildTabBar(ActivityState state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          for (final tab in ActivityTab.values)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(activityProvider.notifier).setActiveTab(tab);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tab.displayText,
                      style: AppTypography.labelMedium.copyWith(
                        color: state.activeTab == tab
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: state.activeTab == tab
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (state.activeTab == tab)
                      Container(
                        height: 2,
                        width: 30,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      )
                    else
                      const SizedBox(height: 2),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(ActivityState state) {
    final activities = _getActivitiesForTab(state);

    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No ${state.activeTab.displayText.toLowerCase()} activities',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];

        // Show mystery card for mystery experiences in upcoming tab
        if (activity.isMystery && state.activeTab == ActivityTab.upcoming) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: MysteryCountdownCard(
              activity: activity,
              onTap: () {
                // Navigate to activity details
              },
            ),
          );
        }

        // Regular activity card
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: ActivityCard(
            activity: activity,
            onTap: () {
              // Navigate to activity details
            },
            onMenuTap: () {
              _showActivityMenu(context);
            },
            onViewAllParticipants: () {
              // Navigate to participants list
            },
          ),
        );
      },
    );
  }

  List _getActivitiesForTab(ActivityState state) {
    switch (state.activeTab) {
      case ActivityTab.ongoing:
        return state.ongoingActivities;
      case ActivityTab.upcoming:
        return state.upcomingActivities;
      case ActivityTab.past:
        return state.pastActivities;
    }
  }

  void _showActivityMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Activity'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle share
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Report Activity'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle report
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: AppColors.error),
                title: Text(
                  'Cancel Activity',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Handle cancel
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
