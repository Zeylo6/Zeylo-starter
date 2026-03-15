import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<void> submitReview(ReviewEntity review);
  Future<List<ReviewEntity>> getReviewsForExperience(String experienceId);
  Future<void> toggleHelpful(String reviewId, String userId);
  Future<void> reportReview(String reviewId, String reporterId, String hostId);
  Future<void> deleteReview(String reviewId);
}
