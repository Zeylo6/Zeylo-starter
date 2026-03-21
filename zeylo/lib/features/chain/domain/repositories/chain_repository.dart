import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chain_entity.dart';

/// Abstract repository for chain (mini trip) operations
///
/// Defines the contract for chain data layer operations.
/// Implementations handle Firebase interactions.
abstract class ChainRepository {
  /// Create a new chain
  ///
  /// Takes chain entity data and creates a new chain in Firebase
  /// Returns the created chain entity with generated ID on success
  Future<Either<Failure, ChainEntity>> createChain(ChainEntity chain);

  /// Get all chains for a specific user
  ///
  /// Retrieves all chains created by the given user
  /// Returns a list of chains ordered by creation date (newest first)
  Future<Either<Failure, List<ChainEntity>>> getChainsByUserId(String userId);

  /// Get a single chain by ID
  ///
  /// Retrieves details of a specific chain
  Future<Either<Failure, ChainEntity>> getChainById(String chainId);

  /// Update an existing chain
  ///
  /// Updates chain details including name, description, experiences, etc
  Future<Either<Failure, ChainEntity>> updateChain(ChainEntity chain);

  /// Delete a chain
  ///
  /// Deletes a chain from the database
  Future<Either<Failure, void>> deleteChain(String chainId);

  /// Get suggested chains based on interests
  ///
  /// Returns chains that match the given interests and destination
  Future<Either<Failure, List<ChainEntity>>> getSuggestedChains(
    String destinationCity,
    List<String> interests,
  );

  /// Publish a chain
  ///
  /// Makes a draft chain active for booking
  Future<Either<Failure, ChainEntity>> publishChain(String chainId);

  /// Archive a chain
  ///
  /// Archive a chain (removes from active listings)
  Future<Either<Failure, ChainEntity>> archiveChain(String chainId);

  /// Enhance chain prompt using AI
  Future<Either<Failure, String>> enhancePrompt(String prompt);

  /// Generate chain experiences based on advanced prompt
  Future<Either<Failure, List<ChainExperience>>> generateChainExperiences({
    required String prompt,
    required String location,
    required String date,
    required String totalTime,
    required List<String> interests,
  });
}
