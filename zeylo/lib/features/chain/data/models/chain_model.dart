import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../chain/domain/entities/chain_entity.dart';

/// FireStore model for chains (mini trips)
///
/// Handles serialization/deserialization of chain data
/// to/from Firebase Firestore
class ChainModel extends ChainEntity {
  const ChainModel({
    required super.id,
    required super.name,
    required super.description,
    required super.createdBy,
    required super.destinationCity,
    required super.date,
    required super.totalTime,
    required super.interests,
    required super.experiences,
    required super.totalPrice,
    required super.status,
    required super.createdAt,
  });

  factory ChainModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ChainModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      createdBy: data['createdBy'] ?? '',
      destinationCity: data['destinationCity'] ?? '',
      date: data['date'] ?? '',
      totalTime: _parseChainDuration(data['totalTime'] ?? 'fullDay'),
      interests: List<String>.from(data['interests'] ?? []),
      experiences: _parseExperiences(data['experiences'] ?? []),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: _parseChainStatus(data['status'] ?? 'draft'),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory ChainModel.fromJson(Map<String, dynamic> json) {
    return ChainModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdBy: json['createdBy'] ?? '',
      destinationCity: json['destinationCity'] ?? '',
      date: json['date'] ?? '',
      totalTime: _parseChainDuration(json['totalTime'] ?? 'fullDay'),
      interests: List<String>.from(json['interests'] ?? []),
      experiences: _parseExperiences(json['experiences'] ?? []),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: _parseChainStatus(json['status'] ?? 'draft'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'destinationCity': destinationCity,
      'date': date,
      'totalTime': totalTime.name,
      'interests': interests,
      'experiences': experiences
          .map((e) => {
                'experienceId': e.experienceId,
                'title': e.title,
                'startTime': e.startTime,
                'endTime': e.endTime,
                'duration': e.duration,
                'price': e.price,
                'isOvernight': e.isOvernight,
                'imageUrl': e.imageUrl,
                'category': e.category,
                'hostId': e.hostId,
              })
          .toList(),
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'destinationCity': destinationCity,
      'date': date,
      'totalTime': totalTime.name,
      'interests': interests,
      'experiences': experiences
          .map((e) => {
                'experienceId': e.experienceId,
                'title': e.title,
                'startTime': e.startTime,
                'endTime': e.endTime,
                'duration': e.duration,
                'price': e.price,
                'isOvernight': e.isOvernight,
                'imageUrl': e.imageUrl,
                'category': e.category,
                'hostId': e.hostId,
              })
          .toList(),
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ChainEntity toEntity() {
    return ChainEntity(
      id: id,
      name: name,
      description: description,
      createdBy: createdBy,
      destinationCity: destinationCity,
      date: date,
      totalTime: totalTime,
      interests: interests,
      experiences: experiences,
      totalPrice: totalPrice,
      status: status,
      createdAt: createdAt,
    );
  }

  @override
  ChainModel copyWith({
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
    return ChainModel(
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
}

ChainDuration _parseChainDuration(String value) {
  return ChainDuration.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ChainDuration.fullDay,
  );
}

ChainStatus _parseChainStatus(String value) {
  return ChainStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ChainStatus.draft,
  );
}

List<ChainExperience> _parseExperiences(List<dynamic> experiences) {
  return experiences.map((e) {
    final exp = Map<String, dynamic>.from(e as Map);
    return ChainExperience(
      experienceId: exp['experienceId'] ?? '',
      title: exp['title'] ?? '',
      startTime: exp['startTime'] ?? '',
      endTime: exp['endTime'] ?? '',
      duration: (exp['duration'] ?? 0).toDouble(),
      price: (exp['price'] ?? 0).toDouble(),
      isOvernight: exp['isOvernight'] ?? false,
      imageUrl: exp['imageUrl'] ?? '',
      category: exp['category'] ?? '',
      hostId: exp['hostId'] ?? '',
    );
  }).toList();
}