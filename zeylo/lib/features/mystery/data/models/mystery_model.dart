import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../mystery/domain/entities/mystery_entity.dart';

/// FireStore model for mystery bookings
///
/// Handles serialization/deserialization of mystery data
/// to/from Firebase Firestore
class MysteryModel extends MysteryEntity {
  const MysteryModel({
    required super.id,
    required super.userId,
    required super.location,
    required super.date,
    required super.time,
    required super.budgetMin,
    required super.budgetMax,
    required super.experienceType,
    required super.status,
    super.matchedExperienceId,
    super.matchedPrice,
    super.teaserDescription,
    super.vibe,
    super.preparationNotes,
    super.revealedAt,
    required super.createdAt,
  });

  /// Create a model from a Firestore document
  factory MysteryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return MysteryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      location: data['location'] ?? '',
      date: data['date'] ?? '',
      time: _parseTimeOfDay(data['time'] ?? 'morning'),
      budgetMin: (data['budgetMin'] ?? 0).toDouble(),
      budgetMax: (data['budgetMax'] ?? 0).toDouble(),
      experienceType: _parseExperienceType(data['experienceType'] ?? 'surpriseMe'),
      status: _parseStatus(data['status'] ?? 'pending'),
      matchedExperienceId: data['matchedExperienceId'],
      matchedPrice: data['matchedPrice'] != null ? (data['matchedPrice'] as num).toDouble() : null,
      teaserDescription: data['teaserDescription'],
      vibe: data['vibe'],
      preparationNotes: data['preparationNotes'],
      revealedAt: data['revealedAt'] != null
          ? (data['revealedAt'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Create a model from JSON
  factory MysteryModel.fromJson(Map<String, dynamic> json) {
    return MysteryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      location: json['location'] ?? '',
      date: json['date'] ?? '',
      time: _parseTimeOfDay(json['time'] ?? 'morning'),
      budgetMin: (json['budgetMin'] ?? 0).toDouble(),
      budgetMax: (json['budgetMax'] ?? 0).toDouble(),
      experienceType: _parseExperienceType(json['experienceType'] ?? 'surpriseMe'),
      status: _parseStatus(json['status'] ?? 'pending'),
      matchedExperienceId: json['matchedExperienceId'],
      matchedPrice: json['matchedPrice'] != null ? (json['matchedPrice'] as num).toDouble() : null,
      teaserDescription: json['teaserDescription'],
      vibe: json['vibe'],
      preparationNotes: json['preparationNotes'],
      revealedAt: json['revealedAt'] != null
          ? DateTime.parse(json['revealedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert model to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'location': location,
      'date': date,
      'time': time.name,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'experienceType': experienceType.name,
      'status': status.name,
      'matchedExperienceId': matchedExperienceId,
      'matchedPrice': matchedPrice,
      'teaserDescription': teaserDescription,
      'vibe': vibe,
      'preparationNotes': preparationNotes,
      'revealedAt': revealedAt != null ? Timestamp.fromDate(revealedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'location': location,
      'date': date,
      'time': time.name,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'experienceType': experienceType.name,
      'status': status.name,
      'matchedExperienceId': matchedExperienceId,
      'matchedPrice': matchedPrice,
      'teaserDescription': teaserDescription,
      'vibe': vibe,
      'preparationNotes': preparationNotes,
      'revealedAt': revealedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to entity
  MysteryEntity toEntity() {
    return MysteryEntity(
      id: id,
      userId: userId,
      location: location,
      date: date,
      time: time,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      experienceType: experienceType,
      status: status,
      matchedExperienceId: matchedExperienceId,
      matchedPrice: matchedPrice,
      teaserDescription: teaserDescription,
      vibe: vibe,
      preparationNotes: preparationNotes,
      revealedAt: revealedAt,
      createdAt: createdAt,
    );
  }

  /// Create a copy of this model with some fields replaced
  @override
  MysteryModel copyWith({
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
    double? matchedPrice,
    String? teaserDescription,
    String? vibe,
    String? preparationNotes,
    DateTime? revealedAt,
    DateTime? createdAt,
  }) {
    return MysteryModel(
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
      matchedPrice: matchedPrice ?? this.matchedPrice,
      teaserDescription: teaserDescription ?? this.teaserDescription,
      vibe: vibe ?? this.vibe,
      preparationNotes: preparationNotes ?? this.preparationNotes,
      revealedAt: revealedAt ?? this.revealedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Parse time of day from string
MysteryTimeOfDay _parseTimeOfDay(String value) {
  return MysteryTimeOfDay.values.firstWhere(
    (e) => e.name == value,
    orElse: () => MysteryTimeOfDay.morning,
  );
}

/// Parse experience type from string
MysteryExperienceType _parseExperienceType(String value) {
  return MysteryExperienceType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => MysteryExperienceType.surpriseMe,
  );
}

/// Parse status from string
MysteryStatus _parseStatus(String value) {
  return MysteryStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => MysteryStatus.pending,
  );
}
