/// Chain (mini trip) entity
///
/// Represents a collection of connected experiences forming a mini trip.
/// A chain allows users to book multiple experiences in a logical sequence.
class ChainEntity {
  /// Unique identifier for the chain
  final String id;

  /// Name of the chain/mini trip
  final String name;

  /// Description of the chain
  final String description;

  /// User ID who created this chain
  final String createdBy;

  /// Destination city for the chain
  final String destinationCity;

  /// Date of the chain in yyyy-MM-dd format
  final String date;

  /// Total time available for the chain
  final ChainDuration totalTime;

  /// List of interests for this chain
  final List<String> interests;

  /// Ordered list of experiences in the chain
  final List<ChainExperience> experiences;

  /// Total price for all experiences in the chain
  final double totalPrice;

  /// Status of the chain
  final ChainStatus status;

  /// DateTime when the chain was created
  final DateTime createdAt;

  const ChainEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.destinationCity,
    required this.date,
    required this.totalTime,
    required this.interests,
    required this.experiences,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  /// Create a copy of this entity with some fields replaced
  ChainEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    String? destinationCity,
    String? date,
    ChainDuration? totalTime,
    List<String>? interests,
    List<ChainExperience>? experiences,
    double? totalPrice,
    ChainStatus? status,
    DateTime? createdAt,
  }) {
    return ChainEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      destinationCity: destinationCity ?? this.destinationCity,
      date: date ?? this.date,
      totalTime: totalTime ?? this.totalTime,
      interests: interests ?? this.interests,
      experiences: experiences ?? this.experiences,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'ChainEntity(id: $id, name: $name, destinationCity: $destinationCity, '
      'totalTime: $totalTime, experiences: ${experiences.length}, totalPrice: $totalPrice)';
}

/// Individual experience within a chain
class ChainExperience {
  /// Experience ID
  final String experienceId;

  /// Experience title
  final String title;

  /// Start time (HH:mm format)
  final String startTime;

  /// End time (HH:mm format)
  final String endTime;

  /// Duration in hours
  final double duration;

  /// Price for this experience
  final double price;

  /// Whether this is an overnight experience
  final bool isOvernight;

  const ChainExperience({
    required this.experienceId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.price,
    required this.isOvernight,
  });

  ChainExperience copyWith({
    String? experienceId,
    String? title,
    String? startTime,
    String? endTime,
    double? duration,
    double? price,
    bool? isOvernight,
  }) {
    return ChainExperience(
      experienceId: experienceId ?? this.experienceId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      isOvernight: isOvernight ?? this.isOvernight,
    );
  }
}

/// Duration options for chains
enum ChainDuration {
  halfDay('Half Day', '4-6 hours'),
  fullDay('Full Day', '8-10 hours'),
  weekend('Weekend', '2 days');

  final String label;
  final String timeRange;

  const ChainDuration(this.label, this.timeRange);
}

/// Status of a chain
enum ChainStatus {
  draft,
  active,
  archived,
  completed;

  bool get isDraft => this == ChainStatus.draft;
  bool get isActive => this == ChainStatus.active;
  bool get isArchived => this == ChainStatus.archived;
  bool get isCompleted => this == ChainStatus.completed;
}

/// Common interests for chain suggestions
final chainInterests = [
  'Food Tours',
  'Photography',
  'Walking Tours',
  'Nightlife',
  'Adventure',
  'Shopping',
  'Museums',
  'Nature',
];
