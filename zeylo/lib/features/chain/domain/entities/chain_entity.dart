/// Chain (mini trip) entity
///
/// Represents a collection of connected experiences forming a mini trip.
/// A chain allows users to book multiple experiences in a logical sequence.
class ChainEntity {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final String destinationCity;
  final String date;
  final ChainDuration totalTime;
  final List<String> interests;
  final List<ChainExperience> experiences;
  final double totalPrice;
  final ChainStatus status;
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
  String toString() =>
      'ChainEntity(id: $id, name: $name, destinationCity: $destinationCity, totalTime: $totalTime, experiences: ${experiences.length}, totalPrice: $totalPrice)';
}

/// Individual experience within a chain
class ChainExperience {
  final String experienceId;
  final String title;
  final String startTime;
  final String endTime;
  final double duration;
  final double price;
  final bool isOvernight;

  /// NEW: real experience image from Firestore
  final String imageUrl;

  /// NEW: category badge label
  final String category;

  /// NEW: host tracking 
  final String hostId;

  const ChainExperience({
    required this.experienceId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.price,
    required this.isOvernight,
    this.imageUrl = '',
    this.category = '',
    this.hostId = '',
  });

  ChainExperience copyWith({
    String? experienceId,
    String? title,
    String? startTime,
    String? endTime,
    double? duration,
    double? price,
    bool? isOvernight,
    String? imageUrl,
    String? category,
    String? hostId,
  }) {
    return ChainExperience(
      experienceId: experienceId ?? this.experienceId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      isOvernight: isOvernight ?? this.isOvernight,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      hostId: hostId ?? this.hostId,
    );
  }
}

enum ChainDuration {
  halfDay('Half Day', '4-6 hours'),
  fullDay('Full Day', '8-10 hours'),
  weekend('Weekend', '2 days');

  final String label;
  final String timeRange;

  const ChainDuration(this.label, this.timeRange);
}

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