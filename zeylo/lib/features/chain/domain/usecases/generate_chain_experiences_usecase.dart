import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chain_entity.dart';
import '../repositories/chain_repository.dart';

class GenerateChainExperiencesParams {
  final String prompt;
  final String location;
  final String date;
  final String totalTime;
  final List<String> interests;

  GenerateChainExperiencesParams({
    required this.prompt,
    required this.location,
    required this.date,
    required this.totalTime,
    required this.interests,
  });
}

class GenerateChainExperiencesUseCase {
  final ChainRepository repository;

  GenerateChainExperiencesUseCase({required this.repository});

  Future<Either<Failure, List<ChainExperience>>> call(
    GenerateChainExperiencesParams params,
  ) async {
    return await repository.generateChainExperiences(
      prompt: params.prompt,
      location: params.location,
      date: params.date,
      totalTime: params.totalTime,
      interests: params.interests,
    );
  }
}