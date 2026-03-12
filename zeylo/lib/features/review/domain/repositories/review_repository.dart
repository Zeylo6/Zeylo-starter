import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<void> submitReview(ReviewEntity review);
  Future<List<ReviewEntity>> getReviewsForExperience(String experienceId);
}
