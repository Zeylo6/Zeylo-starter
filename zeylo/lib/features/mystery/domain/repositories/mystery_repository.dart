import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/mystery_entity.dart';

/// Abstract repository for mystery booking operations
///
/// Defines the contract for mystery booking data layer operations.
/// Implementations handle Firebase interactions.
abstract class MysteryRepository {
  /// Create a new mystery booking
  ///
  /// Takes mystery entity data and creates a new booking in Firebase
  /// Returns the created mystery entity with generated ID on success
  Future<Either<Failure, MysteryEntity>> createMystery(
    MysteryEntity mystery,
  );

  /// Get all mysteries for a specific user
  ///
  /// Retrieves all mystery bookings created by the given user
  /// Returns a list of mysteries ordered by creation date (newest first)
  Future<Either<Failure, List<MysteryEntity>>> getMysteries(String userId);

  /// Get a single mystery by ID
  ///
  /// Retrieves details of a specific mystery booking
  Future<Either<Failure, MysteryEntity>> getMysteryById(String mysteryId);

  /// Reveal a mystery experience
  ///
  /// Marks a mystery as revealed and associates it with a matched experience
  /// Updates the revealedAt timestamp
  Future<Either<Failure, MysteryEntity>> revealMystery(
    String mysteryId,
    String matchedExperienceId,
  );

  /// Accept a revealed mystery experience
  ///
  /// Updates mystery status to accepted
  Future<Either<Failure, MysteryEntity>> acceptMystery(String mysteryId);

  /// Decline a revealed mystery experience
  ///
  /// Updates mystery status to declined
  Future<Either<Failure, MysteryEntity>> declineMystery(String mysteryId);

  /// Update mystery status
  ///
  /// Generic method to update mystery status
  Future<Either<Failure, MysteryEntity>> updateMysteryStatus(
    String mysteryId,
    MysteryStatus status,
  );

  /// Delete a mystery booking
  ///
  /// Deletes a mystery booking from the database
  Future<Either<Failure, void>> deleteMystery(String mysteryId);

  /// Find a matching mystery experience
  Future<Either<Failure, String?>> matchMysteryExperience(
      MysteryEntity mystery);
}
