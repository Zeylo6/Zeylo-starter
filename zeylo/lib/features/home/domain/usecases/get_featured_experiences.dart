import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/experience_entity.dart';
import '../repositories/home_repository.dart';

/// Use case for fetching featured experiences
class GetFeaturedExperiences
    extends UseCase<List<Experience>, NoParams> {
  final HomeRepository repository;

  GetFeaturedExperiences(this.repository);

  @override
  Future<Either<Failure, List<Experience>>> call(NoParams params) {
    return repository.getFeaturedExperiences();
  }
}
