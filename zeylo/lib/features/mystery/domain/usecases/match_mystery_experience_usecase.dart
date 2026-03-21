import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/mystery_entity.dart';
import '../repositories/mystery_repository.dart';

/// Use case for matching a mystery experience
class MatchMysteryExperienceUseCase
    implements UseCase<String?, MatchMysteryExperienceParams> {
  final MysteryRepository repository;

  MatchMysteryExperienceUseCase(this.repository);

  @override
  Future<Either<Failure, String?>> call(
      MatchMysteryExperienceParams params) async {
    final result = await repository.matchAndBookMystery(
      mysteryId: params.mystery.id,
      userId: params.mystery.userId,
      location: params.mystery.location,
      date: params.mystery.date,
      time: params.mystery.time.name,
      budgetMin: params.mystery.budgetMin,
      budgetMax: params.mystery.budgetMax,
      experienceType: params.mystery.experienceType.name,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) => Right(data.matched ? 'Matched' : 'No Match'),
    );
  }
}

class MatchMysteryExperienceParams {
  final MysteryEntity mystery;

  MatchMysteryExperienceParams({required this.mystery});
}
