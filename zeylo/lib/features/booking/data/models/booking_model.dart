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
    super.seekerName,
    super.seekerPhotoUrl,
    super.isEarningsCollected = false,
    super.isMystery = false,
    super.mysteryId,
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
      seekerName: (json['seekerName'] ?? json['seeker_name']) as String?,
      seekerPhotoUrl: (json['seekerPhotoUrl'] ?? json['seeker_photo_url']) as String?,
      isEarningsCollected: json['isEarningsCollected'] as bool? ?? false,
      isMystery: json['isMystery'] as bool? ?? false,
      mysteryId: json['mysteryId'] as String?,
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
      seekerName: (data['seekerName'] ?? data['seeker_name']) as String?,
      seekerPhotoUrl: (data['seekerPhotoUrl'] ?? data['seeker_photo_url']) as String?,
      isEarningsCollected: data['isEarningsCollected'] as bool? ?? false,
      isMystery: data['isMystery'] as bool? ?? false,
      mysteryId: data['mysteryId'] as String?,
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
      'seekerName': seekerName,
      'seekerPhotoUrl': seekerPhotoUrl,
      'isEarningsCollected': isEarningsCollected,
      'isMystery': isMystery,
      'mysteryId': mysteryId,
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
      'seekerName': seekerName,
      'seekerPhotoUrl': seekerPhotoUrl,
      'isEarningsCollected': isEarningsCollected,
      'isMystery': isMystery,
      'mysteryId': mysteryId,
    };
  }

  @override
  BookingModel copyWith({
    String? id,
    String? experienceId,
    String? experienceTitle,
    String? experienceCoverImage,
    String? userId,
    String? hostId,
    DateTime? date,
    String? startTime,
    int? guests,
    double? totalPrice,
    String? status,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRatedByHost,
    bool? isRatedBySeeker,
    String? seekerName,
    String? seekerPhotoUrl,
    bool? isEarningsCollected,
    bool? isMystery,
    String? mysteryId,
  }) {
    return BookingModel(
      id: id ?? this.id,
      experienceId: experienceId ?? this.experienceId,
      experienceTitle: experienceTitle ?? this.experienceTitle,
      experienceCoverImage: experienceCoverImage ?? this.experienceCoverImage,
      userId: userId ?? this.userId,
      hostId: hostId ?? this.hostId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      guests: guests ?? this.guests,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRatedByHost: isRatedByHost ?? this.isRatedByHost,
      isRatedBySeeker: isRatedBySeeker ?? this.isRatedBySeeker,
      seekerName: seekerName ?? this.seekerName,
      seekerPhotoUrl: seekerPhotoUrl ?? this.seekerPhotoUrl,
      isEarningsCollected: isEarningsCollected ?? this.isEarningsCollected,
      isMystery: isMystery ?? this.isMystery,
      mysteryId: mysteryId ?? this.mysteryId,
    );
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
