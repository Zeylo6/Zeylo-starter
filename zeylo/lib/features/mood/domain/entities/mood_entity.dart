/// Mood selection entity
///
/// Represents a user's mood and preferences for discovering experiences.
/// Stores the mood description and AI-enhanced version along with preferences.
class MoodEntity {
  /// Selected mood or custom mood text
  final String mood;

  /// User's description of their mood
  final String description;

  /// AI-enhanced version of the mood description
  final String enhancedDescription;

  /// Mood preferences
  final MoodPreferences preferences;

  /// DateTime when the mood was selected
  final DateTime selectedAt;

  const MoodEntity({
    required this.mood,
    required this.description,
    required this.enhancedDescription,
    required this.preferences,
    required this.selectedAt,
  });

  /// Create a copy of this entity with some fields replaced
  MoodEntity copyWith({
    String? mood,
    String? description,
    String? enhancedDescription,
    MoodPreferences? preferences,
    DateTime? selectedAt,
  }) {
    return MoodEntity(
      mood: mood ?? this.mood,
      description: description ?? this.description,
      enhancedDescription: enhancedDescription ?? this.enhancedDescription,
      preferences: preferences ?? this.preferences,
      selectedAt: selectedAt ?? this.selectedAt,
    );
  }

  @override
  String toString() => 'MoodEntity(mood: $mood, description: $description, '
      'enhancedDescription: $enhancedDescription, preferences: $preferences)';
}

/// Mood preferences
class MoodPreferences {
  /// Preferred location for experience
  final String? location;

  /// Budget range preference
  final BudgetRange? budgetRange;

  /// Preferred time for experience
  final TimePreference? timePreference;

  const MoodPreferences({
    this.location,
    this.budgetRange,
    this.timePreference,
  });

  MoodPreferences copyWith({
    String? location,
    BudgetRange? budgetRange,
    TimePreference? timePreference,
  }) {
    return MoodPreferences(
      location: location ?? this.location,
      budgetRange: budgetRange ?? this.budgetRange,
      timePreference: timePreference ?? this.timePreference,
    );
  }
}

/// Budget range for mood preferences
class BudgetRange {
  /// Minimum budget in dollars
  final double min;

  /// Maximum budget in dollars
  final double max;

  const BudgetRange({
    required this.min,
    required this.max,
  });

  BudgetRange copyWith({
    double? min,
    double? max,
  }) {
    return BudgetRange(
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }
}

/// Time preference for mood
enum TimePreference {
  morning('Morning', '6:00 AM - 12:00 PM'),
  afternoon('Afternoon', '12:00 PM - 5:00 PM'),
  evening('Evening', '5:00 PM - 10:00 PM'),
  night('Night', '10:00 PM - 2:00 AM');

  final String label;
  final String timeRange;

  const TimePreference(this.label, this.timeRange);
}

/// Predefined moods for quick selection
enum PredefinedMood {
  happy('Happy', '😊'),
  relaxed('Relaxed', '😌'),
  adventures('Adventurous', '🥾'),
  social('Social', '🌍'),
  creative('Creative', '🎨'),
  energetic('Energetic', '🏃');

  final String label;
  final String emoji;

  const PredefinedMood(this.label, this.emoji);
}

/// Match badge information
class MatchBadge {
  /// Match percentage (0-100)
  final int percentage;

  /// Whether it's a high match (80+%)
  bool get isHighMatch => percentage >= 80;

  /// Badge color based on match percentage
  String get badgeColor {
    if (percentage >= 90) return 'green';
    if (percentage >= 70) return 'yellow';
    return 'red';
  }

  const MatchBadge({required this.percentage});
}
