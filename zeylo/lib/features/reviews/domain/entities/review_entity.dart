/// Review entity representing a review/rating in the Zeylo application
class ReviewEntity {
  /// Unique identifier for the review
  final String id;

  /// Experience ID being reviewed
  final String experienceId;

  /// User ID of the reviewer
  final String userId;

  /// Name of the person who wrote the review
  final String userName;

  /// Profile photo URL of the reviewer
  final String? userPhotoUrl;

  /// Rating given (1-5)
  final double rating;

  /// Review comment/text
  final String comment;

  /// When the review was created
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.experienceId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  /// Create a copy of this review entity with some fields replaced
  ReviewEntity copyWith({
    String? id,
    String? experienceId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      experienceId: experienceId ?? this.experienceId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'ReviewEntity('
      'id: $id, '
      'experienceId: $experienceId, '
      'userId: $userId, '
      'rating: $rating'
      ')';
}
