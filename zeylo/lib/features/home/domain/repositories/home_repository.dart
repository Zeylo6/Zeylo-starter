import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../entities/experience_entity.dart';

/// Abstract repository for home feature
///
/// Defines the contract for data operations related to experiences and categories
abstract class HomeRepository {
  /// Get featured experiences
  Future<Either<Failure, List<Experience>>> getFeaturedExperiences();

  /// Get experiences by category
  Future<Either<Failure, List<Experience>>> getExperiencesByCategory(
    String category,
  );

  /// Get all available categories
  Future<Either<Failure, List<Category>>> getCategories();

  /// Search experiences by query string
  Future<Either<Failure, List<Experience>>> searchExperiences(String query);

  /// Get nearby experiences within radius
  ///
  /// [latitude] - User's latitude
  /// [longitude] - User's longitude
  /// [radius] - Search radius in kilometers
  Future<Either<Failure, List<Experience>>> getNearbyExperiences({
    required double latitude,
    required double longitude,
    required double radius,
  });

  /// Get single experience by ID
  Future<Either<Failure, Experience>> getExperienceById(String id);

  /// Get experience stream by ID
  Stream<Experience> getExperienceStream(String id);

  /// Watch featured experiences
  Stream<List<Experience>> watchFeaturedExperiences();

  /// Watch experiences by category
  Stream<List<Experience>> watchExperiencesByCategory(String category);

  /// Get multiple experiences by IDs
  Future<Either<Failure, List<Experience>>> getExperiencesByIds(List<String> ids);

  /// Get all experiences
  Future<Either<Failure, List<Experience>>> getAllExperiences();
}
