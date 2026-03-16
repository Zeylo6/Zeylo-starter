import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String bookingId;
  final String experienceId;
  final String reviewerId;
  final String revieweeId;
  final String role; // 'host' or 'seeker'
  final double rating; // 1-5
  final String? message;
  final List<String> helpfulUserIds;
  final bool isReported;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.experienceId,
    required this.reviewerId,
    required this.revieweeId,
    required this.role,
    required this.rating,
    this.message,
    this.helpfulUserIds = const [],
    this.isReported = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        experienceId,
        reviewerId,
        revieweeId,
        role,
        rating,
        message,
        helpfulUserIds,
        isReported,
        createdAt,
      ];
}
