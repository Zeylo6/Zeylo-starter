import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/review_entity.dart';

/// Review form state model
class ReviewFormState {
  final double rating;
  final String comment;
  final bool isLoading;
  final String? errorMessage;

  ReviewFormState({
    this.rating = 0,
    this.comment = '',
    this.isLoading = false,
    this.errorMessage,
  });

  ReviewFormState copyWith({
    double? rating,
    String? comment,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReviewFormState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for review form state
class ReviewFormNotifier extends StateNotifier<ReviewFormState> {
  ReviewFormNotifier() : super(ReviewFormState());

  void updateRating(double value) {
    state = state.copyWith(rating: value);
  }

  void updateComment(String value) {
    state = state.copyWith(comment: value);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void reset() {
    state = ReviewFormState();
  }
}

/// Review form provider
final reviewFormProvider =
    StateNotifierProvider<ReviewFormNotifier, ReviewFormState>((ref) {
  return ReviewFormNotifier();
});

/// Experience reviews provider - Fetch all reviews for an experience
final experienceReviewsProvider =
    FutureProvider.family<List<ReviewEntity>, String>((ref, experienceId) async {
  // This would fetch reviews from repository
  // Implementation depends on repository setup
  return [];
});

/// Average rating provider - Calculate average rating for an experience
final experienceAverageRatingProvider =
    FutureProvider.family<double, String>((ref, experienceId) async {
  final reviews = await ref.watch(
    experienceReviewsProvider(experienceId).future,
  );

  if (reviews.isEmpty) return 0;

  final totalRating = reviews.fold<double>(0, (sum, review) => sum + review.rating);
  return totalRating / reviews.length;
});

/// User reviews provider - Get all reviews written by a user
final userReviewsProvider =
    FutureProvider.family<List<ReviewEntity>, String>((ref, userId) async {
  // This would fetch reviews written by the user
  // Implementation depends on repository setup
  return [];
});
