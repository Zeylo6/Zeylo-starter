/// Mystery booking entity
///
/// Represents a mystery experience booking created by a user.
/// The system will match this with an appropriate experience
/// and reveal it 24 hours before the scheduled time.
class MysteryEntity {
  /// Unique identifier for the mystery booking
  final String id;

  /// User ID who created this mystery booking
  final String userId;

  /// City/location where the mystery experience will take place
  final String location;

  /// Date of the experience (yyyy-MM-dd format)
  final String date;

  /// Time of day for the experience
  final MysteryTimeOfDay time;

  /// Minimum budget for the experience in dollars
  final double budgetMin;

  /// Maximum budget for the experience in dollars
  final double budgetMax;

  /// Type/category of experience the user is interested in
  final MysteryExperienceType experienceType;

  /// Current status of the mystery booking
  final MysteryStatus status;

  /// ID of the matched experience (populated when matched)
  final String? matchedExperienceId;

  /// DateTime when the mystery was revealed to the user
  final DateTime? revealedAt;

  /// DateTime when the mystery booking was created
  final DateTime createdAt;

  const MysteryEntity({
    required this.id,
    required this.userId,
    required this.location,
    required this.date,
    required this.time,
    required this.budgetMin,
    required this.budgetMax,
    required this.experienceType,
    required this.status,
    this.matchedExperienceId,
    this.revealedAt,
    required this.createdAt,
  });

  /// Create a copy of this entity with some fields replaced
  MysteryEntity copyWith({
    String? id,
    String? userId,
    String? location,
    String? date,
    MysteryTimeOfDay? time,
    double? budgetMin,
    double? budgetMax,
    MysteryExperienceType? experienceType,
    MysteryStatus? status,
    String? matchedExperienceId,
    DateTime? revealedAt,
    DateTime? createdAt,
  }) {
    return MysteryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      experienceType: experienceType ?? this.experienceType,
      status: status ?? this.status,
      matchedExperienceId: matchedExperienceId ?? this.matchedExperienceId,
      revealedAt: revealedAt ?? this.revealedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'MysteryEntity(id: $id, userId: $userId, location: $location, '
      'date: $date, time: $time, budgetMin: $budgetMin, budgetMax: $budgetMax, '
      'experienceType: $experienceType, status: $status, matchedExperienceId: $matchedExperienceId, '
      'revealedAt: $revealedAt, createdAt: $createdAt)';
}

/// Time of day options for mystery experience
enum MysteryTimeOfDay {
  morning('Morning', '9:00 AM - 12:00 PM'),
  afternoon('Afternoon', '12:00 PM - 5:00 PM'),
  evening('Evening', '5:00 PM - 10:00 PM');

  final String label;
  final String timeRange;

  const MysteryTimeOfDay(this.label, this.timeRange);
}

/// Experience type categories for mystery bookings
enum MysteryExperienceType {
  adventure('Adventure', 'mountain'),
  foodAndDrink('Food & Drink', 'fork-knife'),
  artsAndCulture('Arts & Culture', 'palette'),
  surpriseMe('Surprise Me', 'question');

  final String label;
  final String icon;

  const MysteryExperienceType(this.label, this.icon);
}

/// Status states for mystery bookings
enum MysteryStatus {
  pending,
  matched,
  revealed,
  accepted,
  declined,
  completed;

  bool get isPending => this == MysteryStatus.pending;
  bool get isMatched => this == MysteryStatus.matched;
  bool get isRevealed => this == MysteryStatus.revealed;
  bool get isAccepted => this == MysteryStatus.accepted;
  bool get isDeclined => this == MysteryStatus.declined;
  bool get isCompleted => this == MysteryStatus.completed;
}
