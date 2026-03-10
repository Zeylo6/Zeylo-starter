import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/mystery_entity.dart';
import '../../domain/repositories/mystery_repository.dart';
import '../datasources/mystery_datasource.dart';
import '../models/mystery_model.dart';

/// Implementation of MysteryRepository
///
/// Handles error conversion and delegates to data source
class MysteryRepositoryImpl implements MysteryRepository {
  /// Data source for mystery operations
  final MysteryDataSource dataSource;

  MysteryRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, MysteryEntity>> createMystery(
    MysteryEntity mystery,
  ) async {
    try {
      final model = MysteryModel(
        id: mystery.id,
        userId: mystery.userId,
        location: mystery.location,
        date: mystery.date,
        time: mystery.time,
        budgetMin: mystery.budgetMin,
        budgetMax: mystery.budgetMax,
        experienceType: mystery.experienceType,
        status: mystery.status,
        matchedExperienceId: mystery.matchedExperienceId,
        revealedAt: mystery.revealedAt,
        createdAt: mystery.createdAt,
      );

      final result = await dataSource.createMystery(model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MysteryEntity>>> getMysteries(
    String userId,
  ) async {
    try {
      final models = await dataSource.getMysteries(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MysteryEntity>> getMysteryById(
    String mysteryId,
  ) async {
    try {
      final model = await dataSource.getMysteryById(mysteryId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MysteryEntity>> revealMystery(
    String mysteryId,
    String matchedExperienceId,
  ) async {
    try {
      final model = await dataSource.getMysteryById(mysteryId);
      final updated = model.copyWith(
        status: MysteryStatus.revealed,
        matchedExperienceId: matchedExperienceId,
        revealedAt: DateTime.now(),
      );
      final result = await dataSource.updateMystery(updated);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MysteryEntity>> acceptMystery(
    String mysteryId,
  ) async {
    try {
      final model = await dataSource.getMysteryById(mysteryId);
      final updated = model.copyWith(status: MysteryStatus.accepted);
      final result = await dataSource.updateMystery(updated);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MysteryEntity>> declineMystery(
    String mysteryId,
  ) async {
    try {
      final model = await dataSource.getMysteryById(mysteryId);
      final updated = model.copyWith(status: MysteryStatus.declined);
      final result = await dataSource.updateMystery(updated);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MysteryEntity>> updateMysteryStatus(
    String mysteryId,
    MysteryStatus status,
  ) async {
    try {
      final model = await dataSource.getMysteryById(mysteryId);
      final updated = model.copyWith(status: status);
      final result = await dataSource.updateMystery(updated);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMystery(String mysteryId) async {
    try {
      await dataSource.deleteMystery(mysteryId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> matchMysteryExperience(
    MysteryEntity mystery,
  ) async {
    try {
      final model = MysteryModel(
        id: mystery.id,
        userId: mystery.userId,
        location: mystery.location,
        date: mystery.date,
        time: mystery.time,
        budgetMin: mystery.budgetMin,
        budgetMax: mystery.budgetMax,
        experienceType: mystery.experienceType,
        status: mystery.status,
        matchedExperienceId: mystery.matchedExperienceId,
        revealedAt: mystery.revealedAt,
        createdAt: mystery.createdAt,
      );
      final result = await dataSource.matchMysteryExperience(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
