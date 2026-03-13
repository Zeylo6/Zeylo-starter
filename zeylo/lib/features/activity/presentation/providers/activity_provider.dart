import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/activity_entity.dart';

/// Activity state class
class ActivityState {
  final List<UserActivity> ongoingActivities;
  final List<UserActivity> upcomingActivities;
  final List<UserActivity> pastActivities;
  final ActivityTab activeTab;
  final bool isLoading;
  final String? error;

  const ActivityState({
    this.ongoingActivities = const [],
    this.upcomingActivities = const [],
    this.pastActivities = const [],
    this.activeTab = ActivityTab.ongoing,
    this.isLoading = false,
    this.error,
  });

  ActivityState copyWith({
    List<UserActivity>? ongoingActivities,
    List<UserActivity>? upcomingActivities,
    List<UserActivity>? pastActivities,
    ActivityTab? activeTab,
    bool? isLoading,
    String? error,
  }) {
    return ActivityState(
      ongoingActivities: ongoingActivities ?? this.ongoingActivities,
      upcomingActivities: upcomingActivities ?? this.upcomingActivities,
      pastActivities: pastActivities ?? this.pastActivities,
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Activity tab enum
enum ActivityTab {
  ongoing,
  upcoming,
  past,
}

/// Extension for activity tab display text
extension ActivityTabX on ActivityTab {
  String get displayText {
    switch (this) {
      case ActivityTab.ongoing:
        return 'Ongoing';
      case ActivityTab.upcoming:
        return 'Upcoming';
      case ActivityTab.past:
        return 'Past';
    }
  }
}

/// Activity state notifier
class ActivityNotifier extends Notifier<ActivityState> {
  @override
  ActivityState build() {
    return const ActivityState();
  }

  /// Set the active tab
  void setActiveTab(ActivityTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  /// Load activities (mock implementation)
  Future<void> loadActivities() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with actual repository call
      final mockOngoing = [
        UserActivity(
          id: '1',
          experienceId: 'exp1',
          experienceTitle: 'Street Food Tour',
          date: DateTime.now(),
          startTime: DateTime.now(),
          durationMinutes: 120,
          status: ActivityStatus.ongoing,
          participants: ['url1', 'url2', 'url3', 'url4'],
          spotsLeft: 2,
        ),
      ];

      final mockUpcoming = [
        UserActivity(
          id: '2',
          experienceId: 'exp2',
          experienceTitle: 'Street Food Tour',
          date: DateTime.now().add(const Duration(days: 1)),
          startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
          durationMinutes: 180,
          status: ActivityStatus.upcoming,
          participants: ['url1', 'url2', 'url3', 'url4'],
          spotsLeft: 8,
        ),
        UserActivity(
          id: '3',
          experienceId: 'exp3',
          experienceTitle: 'Mystery Experience',
          date: DateTime.now().add(const Duration(days: 2)),
          startTime: DateTime.now().add(const Duration(days: 2)),
          durationMinutes: 240,
          status: ActivityStatus.upcoming,
          participants: ['url1', 'url2'],
          spotsLeft: 5,
          isMystery: true,
          mysteryUnlockTime: DateTime.now()
              .add(const Duration(hours: 14, minutes: 32, seconds: 45)),
        ),
      ];

      final mockPast = [
        UserActivity(
          id: '4',
          experienceId: 'exp4',
          experienceTitle: 'Street Food Tour',
          date: DateTime.now().subtract(const Duration(days: 2)),
          startTime: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
          durationMinutes: 120,
          status: ActivityStatus.past,
          participants: ['url1', 'url2', 'url3', 'url4'],
          spotsLeft: 0,
        ),
      ];

      state = state.copyWith(
        ongoingActivities: mockOngoing,
        upcomingActivities: mockUpcoming,
        pastActivities: mockPast,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get activities for the active tab
  List<UserActivity> getActiveActivities() {
    switch (state.activeTab) {
      case ActivityTab.ongoing:
        return state.ongoingActivities;
      case ActivityTab.upcoming:
        return state.upcomingActivities;
      case ActivityTab.past:
        return state.pastActivities;
    }
  }
}

/// Activity state provider
final activityProvider = NotifierProvider<ActivityNotifier, ActivityState>(
  () => ActivityNotifier(),
);
