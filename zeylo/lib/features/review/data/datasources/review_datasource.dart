import '../models/review_model.dart';

abstract class ReviewDatasource {
  Future<void> submitReview(ReviewModel review);
  Future<List<ReviewModel>> getReviewsForExperience(String experienceId);
  Future<void> toggleHelpful(String reviewId, String userId);
  Future<void> reportReview(String reviewId, String reporterId, String hostId);
  Future<void> deleteReview(String reviewId);
}
