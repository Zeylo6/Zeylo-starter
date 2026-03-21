import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/mystery_entity.dart';
import '../../domain/repositories/mystery_repository.dart';
import '../datasources/mystery_datasource.dart';
import '../models/mystery_model.dart';

class MysteryRepositoryImpl implements MysteryRepository {
  final MysteryDataSource dataSource;

  MysteryRepositoryImpl({required this.dataSource});

  // ─────────────────────────────────────────────────────────────────────────
  // CRUD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, MysteryEntity>> createMystery(
      MysteryEntity mystery) async {
    try {
      final model = _toModel(mystery);
      final result = await dataSource.createMystery(model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MysteryEntity>>> getMysteries(
      String userId) async {
    try {
      final models = await dataSource.getMysteries(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MysteryEntity>> getMysteryById(
      String mysteryId) async {
    try {
      final model = await dataSource.getMysteryById(mysteryId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MysteryEntity>> revealMystery(
      String mysteryId, String matchedExperienceId) async {
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
      String mysteryId) async {
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
      String mysteryId) async {
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
      String mysteryId, MysteryStatus status) async {
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

  // ─────────────────────────────────────────────────────────────────────────
  // AI MATCHING via Cloud Function
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, MysteryMatchData>> matchAndBookMystery({
    required String mysteryId,
    required String userId,
    required String location,
    required String date,
    required String time,
    required double budgetMin,
    required double budgetMax,
    required String experienceType,
  }) async {
    try {
      final result = await dataSource.matchAndBookMystery(
        mysteryId: mysteryId,
        userId: userId,
        location: location,
        date: date,
        time: time,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        experienceType: experienceType,
      );

      return Right(MysteryMatchData(
        matched: result.matched,
        bookingId: result.bookingId,
        teaserDescription: result.teaserDescription,
        vibe: result.vibe,
        preparationNotes: result.preparationNotes,
        reason: result.reason,
        message: result.message,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper
  // ─────────────────────────────────────────────────────────────────────────

  MysteryModel _toModel(MysteryEntity mystery) {
    return MysteryModel(
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
      teaserDescription: mystery.teaserDescription,
      vibe: mystery.vibe,
      preparationNotes: mystery.preparationNotes,
      revealedAt: mystery.revealedAt,
      createdAt: mystery.createdAt,
    );
  }
}