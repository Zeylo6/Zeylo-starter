import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/mystery_entity.dart';
import '../repositories/mystery_repository.dart';

/// Use case for creating a new mystery booking.
///
/// Flow:
/// 1. Save the mystery document to Firestore (status: pending).
/// 2. Call the Cloud Function to AI-match and create a real booking.
///    - If matched  → update mystery status to "matched", return mystery with teaser.
///    - If no match → return a [Failure] with a user-friendly message.
class CreateMysteryUseCase extends UseCase<MysteryEntity, CreateMysteryParams> {
  final MysteryRepository repository;

  CreateMysteryUseCase({required this.repository});

  @override
  Future<Either<Failure, MysteryEntity>> call(
      CreateMysteryParams params) async {
    // 1. Build the initial mystery entity
    final newMystery = MysteryEntity(
      id: '',
      userId: params.userId,
      location: params.location,
      date: params.date,
      time: params.time,
      budgetMin: params.budgetMin,
      budgetMax: params.budgetMax,
      experienceType: params.experienceType,
      status: MysteryStatus.pending,
      createdAt: DateTime.now(),
    );

    // 2. Save mystery doc to Firestore first (so we have an ID)
    final createResult = await repository.createMystery(newMystery);
    if (createResult.isLeft()) return createResult;

    final savedMystery = createResult.getOrElse(() => newMystery);

    // 3. Call Cloud Function to AI-match + create booking
    final matchResult = await repository.matchAndBookMystery(
      mysteryId: savedMystery.id,
      userId: params.userId,
      location: params.location,
      date: params.date,
      time: params.time.name,
      budgetMin: params.budgetMin,
      budgetMax: params.budgetMax,
      experienceType: params.experienceType.name,
    );

    return matchResult.fold(
      // Matching failed
      (failure) => Left(failure),

      // Got a result from Cloud Function
      (matchData) {
        if (!matchData.matched) {
          return Left(
            ServerFailure(
              message: matchData.message ??
                  'No experiences found matching your location, budget, and preferences. Please try different criteria.',
            ),
          );
        }

        final enrichedMystery = savedMystery.copyWith(
          status: MysteryStatus.matched,
          teaserDescription: matchData.teaserDescription,
          vibe: matchData.vibe,
          preparationNotes: matchData.preparationNotes,
        );

        return Right(enrichedMystery);
      },
    );
  }
}

/// Parameters for creating a mystery booking
class CreateMysteryParams {
  final String userId;
  final String location;
  final String date;
  final MysteryTimeOfDay time;
  final double budgetMin;
  final double budgetMax;
  final MysteryExperienceType experienceType;

  const CreateMysteryParams({
    required this.userId,
    required this.location,
    required this.date,
    required this.time,
    required this.budgetMin,
    required this.budgetMax,
    required this.experienceType,
  });
}