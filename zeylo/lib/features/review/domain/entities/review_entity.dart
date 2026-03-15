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
        createdAt,
      ];
}
