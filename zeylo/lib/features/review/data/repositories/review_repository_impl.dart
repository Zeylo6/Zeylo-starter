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
      helpfulUserIds: review.helpfulUserIds,
      isReported: review.isReported,
      createdAt: review.createdAt,
    );
    await _remoteDatasource.submitReview(model);
  }

  @override
  Future<List<ReviewEntity>> getReviewsForExperience(String experienceId) async {
    return await _remoteDatasource.getReviewsForExperience(experienceId);
  }

  @override
  Stream<List<ReviewEntity>> getReviewsStream(String experienceId) {
    return _remoteDatasource.getReviewsStream(experienceId);
  }

  @override
  Future<void> toggleHelpful(String reviewId, String userId) async {
    await _remoteDatasource.toggleHelpful(reviewId, userId);
  }

  @override
  Future<void> reportReview(
      String reviewId, String reporterId, String hostId) async {
    await _remoteDatasource.reportReview(reviewId, reporterId, hostId);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await _remoteDatasource.deleteReview(reviewId);
  }
}
