import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.bookingId,
    required super.experienceId,
    required super.reviewerId,
    required super.revieweeId,
    required super.role,
    required super.rating,
    super.message,
    required super.createdAt,
  });

  factory ReviewModel.fromFirestore(Map<String, dynamic> doc, String id) {
    return ReviewModel(
      id: id,
      bookingId: doc['bookingId'] ?? '',
      experienceId: doc['experienceId'] ?? '',
      reviewerId: doc['reviewerId'] ?? '',
      revieweeId: doc['revieweeId'] ?? '',
      role: doc['role'] ?? '',
      rating: (doc['rating'] as num?)?.toDouble() ?? 0.0,
      message: doc['message'],
      createdAt: _parseDateTime(doc['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      'experienceId': experienceId,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'role': role,
      'rating': rating,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
