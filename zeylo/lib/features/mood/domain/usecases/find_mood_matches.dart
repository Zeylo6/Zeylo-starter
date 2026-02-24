import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/mood_entity.dart';

/// Use case for finding experiences that match a mood
///
/// Handles the business logic for matching experiences to a mood.
/// Uses the mood description and preferences to find suitable experiences.
class FindMoodMatchesUseCase extends UseCase<List<MoodMatch>, FindMoodMatchesParams> {
  // TODO: Inject mood matching service/repository

  @override
  Future<Either<Failure, List<MoodMatch>>> call(FindMoodMatchesParams params) async {
    // TODO: Implement mood matching logic
    // - Call AI service to analyze mood
    // - Query experiences based on mood and preferences
    // - Score and rank results
    return const Right([]);
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
  });
}
