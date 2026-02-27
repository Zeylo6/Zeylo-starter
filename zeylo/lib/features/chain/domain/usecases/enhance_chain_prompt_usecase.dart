import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/chain_repository.dart';

class EnhanceChainPromptUseCase {
  final ChainRepository repository;

  EnhanceChainPromptUseCase({required this.repository});

  Future<Either<Failure, String>> call(String prompt) async {
    return await repository.enhancePrompt(prompt);
  }
}
