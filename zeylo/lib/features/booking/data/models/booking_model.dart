import '../../domain/entities/booking_entity.dart';

/// Booking model for API/Firestore operations
/// Extends BookingEntity with JSON serialization capabilities
class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.experienceId,
    required super.experienceTitle,
    required super.experienceCoverImage,
    required super.userId,
    required super.hostId,
    required super.date,
    required super.startTime,
    required super.guests,
    required super.totalPrice,
    required super.status,
    required super.paymentStatus,
    required super.createdAt,
    required super.updatedAt,
    super.isRatedByHost = false,
    super.isRatedBySeeker = false,
  });

  /// Create a BookingModel from JSON
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      experienceId: json['experienceId'] as String,
      experienceTitle: json['experienceTitle'] as String,
      experienceCoverImage: json['experienceCoverImage'] as String,
      userId: json['userId'] as String,
      hostId: json['hostId'] as String,
      date: _parseDateTime(json['date']),
      startTime: json['startTime'] as String,
      guests: json['guests'] as int,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      isRatedByHost: json['isRatedByHost'] as bool? ?? false,
      isRatedBySeeker: json['isRatedBySeeker'] as bool? ?? false,
    );
  }

  /// Create a BookingModel from Firestore document
  factory BookingModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return BookingModel(
      id: documentId,
      experienceId: data['experienceId'] as String,
      experienceTitle: data['experienceTitle'] as String,
      experienceCoverImage: data['experienceCoverImage'] as String,
      userId: data['userId'] as String,
      hostId: data['hostId'] as String,
      date: (data['date'] as dynamic)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] as String,
      guests: data['guests'] as int,
      totalPrice: (data['totalPrice'] as num).toDouble(),
      status: data['status'] as String? ?? 'pending',
      paymentStatus: data['paymentStatus'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      isRatedByHost: data['isRatedByHost'] as bool? ?? false,
      isRatedBySeeker: data['isRatedBySeeker'] as bool? ?? false,
    );
  }

  /// Convert BookingModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'experienceId': experienceId,
      'experienceTitle': experienceTitle,
      'experienceCoverImage': experienceCoverImage,
      'userId': userId,
      'hostId': hostId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'guests': guests,
      'totalPrice': totalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isRatedByHost': isRatedByHost,
      'isRatedBySeeker': isRatedBySeeker,
    };
  }

  /// Convert BookingModel to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'experienceId': experienceId,
      'experienceTitle': experienceTitle,
      'experienceCoverImage': experienceCoverImage,
      'userId': userId,
      'hostId': hostId,
      'date': date,
      'startTime': startTime,
      'guests': guests,
      'totalPrice': totalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isRatedByHost': isRatedByHost,
      'isRatedBySeeker': isRatedBySeeker,
    };
  }

  /// Parse DateTime from various formats
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue is DateTime) {
      return dateValue;
    } else if (dateValue is String) {
      return DateTime.parse(dateValue);
    }
    return DateTime.now();
  }
}
