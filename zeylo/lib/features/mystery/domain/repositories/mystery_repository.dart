import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/mystery_entity.dart';

/// Result returned from the AI mystery matching Cloud Function
class MysteryMatchData {
  final bool matched;
  final String? bookingId;
  final String? teaserDescription;
  final String? vibe;
  final String? preparationNotes;
  final String? reason;
  final String? message;

  const MysteryMatchData({
    required this.matched,
    this.bookingId,
    this.teaserDescription,
    this.vibe,
    this.preparationNotes,
    this.reason,
    this.message,
  });
}

/// Abstract repository for mystery booking operations
abstract class MysteryRepository {
  Future<Either<Failure, MysteryEntity>> createMystery(MysteryEntity mystery);
  Future<Either<Failure, List<MysteryEntity>>> getMysteries(String userId);
  Future<Either<Failure, MysteryEntity>> getMysteryById(String mysteryId);
  Future<Either<Failure, MysteryEntity>> revealMystery(
    String mysteryId,
    String matchedExperienceId,
  );
  Future<Either<Failure, MysteryEntity>> acceptMystery(String mysteryId);
  Future<Either<Failure, MysteryEntity>> declineMystery(String mysteryId);
  Future<Either<Failure, MysteryEntity>> updateMysteryStatus(
    String mysteryId,
    MysteryStatus status,
  );
  Future<Either<Failure, void>> deleteMystery(String mysteryId);

  /// Match mystery to a real experience via Cloud Function AI matcher.
  /// Creates the booking and returns teaser content.
  Future<Either<Failure, MysteryMatchData>> matchAndBookMystery({
    required String mysteryId,
    required String userId,
    required String location,
    required String date,
    required String time,
    required double budgetMin,
    required double budgetMax,
    required String experienceType,
  });
}