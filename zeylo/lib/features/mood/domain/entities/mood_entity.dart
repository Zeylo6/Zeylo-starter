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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntity &&
          runtimeType == other.runtimeType &&
          mood == other.mood &&
          description == other.description &&
          enhancedDescription == other.enhancedDescription &&
          preferences == other.preferences &&
          selectedAt == other.selectedAt;

  @override
  int get hashCode =>
      mood.hashCode ^
      description.hashCode ^
      enhancedDescription.hashCode ^
      preferences.hashCode ^
      selectedAt.hashCode;

  @override
  String toString() => 'MoodEntity(mood: $mood, description: $description, '
      'enhancedDescription: $enhancedDescription, preferences: $preferences)';
}

/// Mood preferences
///
/// Uses sentinel-based copyWith pattern to allow clearing nullable fields
/// back to null.
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

  /// Creates a copy with replaced fields.
  ///
  /// Pass explicit `null` wrapped in the sentinel to clear a field:
  /// ```dart
  /// preferences.copyWith(clearLocation: true) // sets location to null
  /// ```
  MoodPreferences copyWith({
    String? location,
    bool clearLocation = false,
    BudgetRange? budgetRange,
    bool clearBudgetRange = false,
    TimePreference? timePreference,
    bool clearTimePreference = false,
  }) {
    return MoodPreferences(
      location: clearLocation ? null : (location ?? this.location),
      budgetRange:
          clearBudgetRange ? null : (budgetRange ?? this.budgetRange),
      timePreference:
          clearTimePreference ? null : (timePreference ?? this.timePreference),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodPreferences &&
          runtimeType == other.runtimeType &&
          location == other.location &&
          budgetRange == other.budgetRange &&
          timePreference == other.timePreference;

  @override
  int get hashCode =>
      location.hashCode ^ budgetRange.hashCode ^ timePreference.hashCode;

  @override
  String toString() => 'MoodPreferences(location: $location, '
      'budgetRange: $budgetRange, timePreference: $timePreference)';
}

/// Budget range for mood preferences
class BudgetRange {
  /// Minimum budget in dollars
  final double min;

  /// Maximum budget in dollars
  final double max;

  /// Creates a [BudgetRange] with validation.
  ///
  /// Asserts that [min] >= 0, [max] >= 0, and [min] <= [max].
  const BudgetRange({
    required this.min,
    required this.max,
  })  : assert(min >= 0, 'min must be non-negative, got $min'),
        assert(max >= 0, 'max must be non-negative, got $max'),
        assert(min <= max, 'min ($min) must be <= max ($max)');

  BudgetRange copyWith({
    double? min,
    double? max,
  }) {
    return BudgetRange(
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetRange &&
          runtimeType == other.runtimeType &&
          min == other.min &&
          max == other.max;

  @override
  int get hashCode => min.hashCode ^ max.hashCode;

  @override
  String toString() => 'BudgetRange(min: $min, max: $max)';
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
  adventurous('Adventurous', '🥾'),
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

  /// Creates a [MatchBadge] with validation.
  ///
  /// Asserts that [percentage] is between 0 and 100 inclusive.
  const MatchBadge({required this.percentage})
      : assert(percentage >= 0 && percentage <= 100,
            'percentage must be 0-100, got $percentage');

  /// Whether it's a high match (80+%)
  bool get isHighMatch => percentage >= 80;

  /// Badge color based on match percentage
  String get badgeColor {
    if (percentage >= 90) return 'green';
    if (percentage >= 70) return 'yellow';
    return 'red';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchBadge &&
          runtimeType == other.runtimeType &&
          percentage == other.percentage;

  @override
  int get hashCode => percentage.hashCode;

  @override
  String toString() => 'MatchBadge(percentage: $percentage)';
}
