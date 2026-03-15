import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_datasource.dart';
import '../models/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewDatasource _remoteDatasource;

  ReviewRepositoryImpl(this._remoteDatasource);

  @override
  Future<void> submitReview(ReviewEntity review) async {
    final model = ReviewModel(
      id: review.id,
      bookingId: review.bookingId,
      experienceId: review.experienceId,
      reviewerId: review.reviewerId,
      revieweeId: review.revieweeId,
      role: review.role,
      rating: review.rating,
      message: review.message,
      createdAt: review.createdAt,
    );
    await _remoteDatasource.submitReview(model);
  }

  @override
  Future<List<ReviewEntity>> getReviewsForExperience(String experienceId) async {
    return await _remoteDatasource.getReviewsForExperience(experienceId);
  }
}
