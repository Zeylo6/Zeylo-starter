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
    return await repository.matchMysteryExperience(params.mystery);
  }
}

class MatchMysteryExperienceParams {
  final MysteryEntity mystery;

  MatchMysteryExperienceParams({required this.mystery});
}
