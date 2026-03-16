import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/mood_entity.dart';

/// Use case for finding experiences that match a mood
///
/// Handles the business logic for matching experiences to a mood.
/// Uses the mood description and preferences to find suitable experiences.
class FindMoodMatchesUseCase
    extends UseCase<List<MoodMatch>, FindMoodMatchesParams> {
  // TODO: Inject mood matching service/repository

  @override
  Future<Either<Failure, List<MoodMatch>>> call(
      FindMoodMatchesParams params) async {
    try {
      // Validate params before processing
      if (params.mood.description.isEmpty) {
        return Left(
            ValidationFailure(message: 'Mood description cannot be empty'));
      }

      if (params.limit != null && params.limit! <= 0) {
        return Left(
            ValidationFailure(message: 'Limit must be a positive number'));
      }

      // TODO: Implement mood matching logic
      // - Call AI service to analyze mood
      // - Query experiences based on mood and preferences
      // - Score and rank results
      return const Right([]);
    } catch (e, stackTrace) {
      return Left(UnknownFailure(
        message: 'Failed to find mood matches: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }
}

/// Parameters for finding mood matches
class FindMoodMatchesParams {
  /// The mood entity with description and preferences
  final MoodEntity mood;

  /// Optional limit on number of results
  final int? limit;

  const FindMoodMatchesParams({
    required this.mood,
    this.limit = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FindMoodMatchesParams &&
          runtimeType == other.runtimeType &&
          mood == other.mood &&
          limit == other.limit;

  @override
  int get hashCode => mood.hashCode ^ limit.hashCode;

  @override
  String toString() => 'FindMoodMatchesParams(mood: $mood, limit: $limit)';
}

/// Mood match result
class MoodMatch {
  /// Experience ID
  final String experienceId;

  /// Experience title
  final String title;

  /// Experience description
  final String description;

  /// Match percentage (0-100)
  final int matchPercentage;

  /// Experience category
  final String category;

  /// Experience location
  final String location;

  /// Experience price
  final double price;

  /// Experience image URL
  final String imageUrl;

  /// Host name
  final String hostName;

  /// Host rating
  final double rating;

  /// Match badge derived from match percentage
  MatchBadge get matchBadge => MatchBadge(percentage: matchPercentage);

  const MoodMatch({
    required this.experienceId,
    required this.title,
    required this.description,
    required this.matchPercentage,
    required this.category,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.hostName,
    required this.rating,
  })  : assert(matchPercentage >= 0 && matchPercentage <= 100,
            'matchPercentage must be 0-100'),
        assert(price >= 0, 'price must be non-negative'),
        assert(rating >= 0 && rating <= 5, 'rating must be 0-5');

  /// Create a copy with some fields replaced
  MoodMatch copyWith({
    String? experienceId,
    String? title,
    String? description,
    int? matchPercentage,
    String? category,
    String? location,
    double? price,
    String? imageUrl,
    String? hostName,
    double? rating,
  }) {
    return MoodMatch(
      experienceId: experienceId ?? this.experienceId,
      title: title ?? this.title,
      description: description ?? this.description,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      category: category ?? this.category,
      location: location ?? this.location,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      hostName: hostName ?? this.hostName,
      rating: rating ?? this.rating,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodMatch &&
          runtimeType == other.runtimeType &&
          experienceId == other.experienceId &&
          matchPercentage == other.matchPercentage;

  @override
  int get hashCode => experienceId.hashCode ^ matchPercentage.hashCode;

  @override
  String toString() => 'MoodMatch(experienceId: $experienceId, title: $title, '
      'matchPercentage: $matchPercentage)';
}
