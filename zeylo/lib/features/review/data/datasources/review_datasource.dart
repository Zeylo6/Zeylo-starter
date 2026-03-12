import '../models/review_model.dart';

abstract class ReviewDatasource {
  Future<void> submitReview(ReviewModel review);
  Future<List<ReviewModel>> getReviewsForExperience(String experienceId);
}
