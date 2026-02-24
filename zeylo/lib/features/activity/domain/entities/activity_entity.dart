/// Activity entity representing a user's activity participation
///
/// Contains information about an experience a user is or has participated in,
/// including timing, participants, and status information.
class UserActivity {
  /// Unique identifier for the activity
  final String id;

  /// ID of the associated experience
  final String experienceId;

  /// Title of the experience
  final String experienceTitle;

  /// Date of the activity
  final DateTime date;

  /// Start time of the activity
  final DateTime startTime;

  /// Duration in minutes
  final int durationMinutes;

  /// Activity status: ongoing, upcoming, or past
  final ActivityStatus status;

  /// List of participant avatars URLs
  final List<String> participants;

  /// Number of spots left
  final int spotsLeft;

  /// Whether this is a mystery experience
  final bool isMystery;

  /// When the mystery will unlock (for mystery experiences)
  final DateTime? mysteryUnlockTime;

  const UserActivity({
    required this.id,
    required this.experienceId,
    required this.experienceTitle,
    required this.date,
    required this.startTime,
    required this.durationMinutes,
    required this.status,
    required this.participants,
    required this.spotsLeft,
    this.isMystery = false,
    this.mysteryUnlockTime,
  });

  /// Copy with method for immutability
  UserActivity copyWith({
    String? id,
    String? experienceId,
    String? experienceTitle,
    DateTime? date,
    DateTime? startTime,
    int? durationMinutes,
    ActivityStatus? status,
    List<String>? participants,
    int? spotsLeft,
    bool? isMystery,
    DateTime? mysteryUnlockTime,
  }) {
    return UserActivity(
      id: id ?? this.id,
      experienceId: experienceId ?? this.experienceId,
      experienceTitle: experienceTitle ?? this.experienceTitle,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      participants: participants ?? this.participants,
      spotsLeft: spotsLeft ?? this.spotsLeft,
      isMystery: isMystery ?? this.isMystery,
      mysteryUnlockTime: mysteryUnlockTime ?? this.mysteryUnlockTime,
    );
  }

  @override
  String toString() => 'UserActivity(id: $id, experienceTitle: $experienceTitle, status: $status)';
}

/// Enum representing the status of an activity
enum ActivityStatus {
  ongoing,
  upcoming,
  past,
}

/// Extension to get display text for activity status
extension ActivityStatusX on ActivityStatus {
  String get displayText {
    switch (this) {
      case ActivityStatus.ongoing:
        return 'Ongoing';
      case ActivityStatus.upcoming:
        return 'Upcoming';
      case ActivityStatus.past:
        return 'Past';
    }
  }
}
