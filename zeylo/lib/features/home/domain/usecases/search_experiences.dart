import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/experience_entity.dart';
import '../repositories/home_repository.dart';

/// Parameters for search experiences use case
class SearchExperiencesParams extends Equatable {
  final String query;

  const SearchExperiencesParams({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Use case for searching experiences
class SearchExperiences
    extends UseCase<List<Experience>, SearchExperiencesParams> {
  final HomeRepository repository;

  SearchExperiences(this.repository);

  @override
  Future<Either<Failure, List<Experience>>> call(SearchExperiencesParams params) {
    return repository.searchExperiences(params.query);
  }
}
