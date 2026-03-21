import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chain_entity.dart';
import '../../domain/repositories/chain_repository.dart';
import '../datasources/chain_datasource.dart';
import '../models/chain_model.dart';

class ChainRepositoryImpl implements ChainRepository {
  final ChainDataSource dataSource;

  ChainRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, ChainEntity>> createChain(
    ChainEntity chain,
  ) async {
    try {
      final model = ChainModel(
        id: chain.id,
        name: chain.name,
        description: chain.description,
        createdBy: chain.createdBy,
        destinationCity: chain.destinationCity,
        date: chain.date,
        totalTime: chain.totalTime,
        interests: chain.interests,
        experiences: chain.experiences,
        totalPrice: chain.totalPrice,
        status: chain.status,
        createdAt: chain.createdAt,
      );

      final result = await dataSource.createChain(model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChainEntity>>> getChainsByUserId(
    String userId,
  ) async {
    try {
      final models = await dataSource.getChainsByUserId(userId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChainEntity>> getChainById(String chainId) async {
    try {
      final model = await dataSource.getChainById(chainId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChainEntity>> updateChain(
    ChainEntity chain,
  ) async {
    try {
      final model = ChainModel(
        id: chain.id,
        name: chain.name,
        description: chain.description,
        createdBy: chain.createdBy,
        destinationCity: chain.destinationCity,
        date: chain.date,
        totalTime: chain.totalTime,
        interests: chain.interests,
        experiences: chain.experiences,
        totalPrice: chain.totalPrice,
        status: chain.status,
        createdAt: chain.createdAt,
      );

      final result = await dataSource.updateChain(model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChain(String chainId) async {
    try {
      await dataSource.deleteChain(chainId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChainEntity>>> getSuggestedChains(
    String destinationCity,
    List<String> interests,
  ) async {
    try {
      final models =
          await dataSource.getSuggestedChains(destinationCity, interests);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChainEntity>> publishChain(String chainId) async {
    try {
      final model = await dataSource.getChainById(chainId);
      final updated = model.copyWith(status: ChainStatus.active);
      final result = await dataSource.updateChain(updated);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChainEntity>> archiveChain(String chainId) async {
    try {
      final model = await dataSource.getChainById(chainId);
      final updated = model.copyWith(status: ChainStatus.archived);
      final result = await dataSource.updateChain(updated);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> enhancePrompt(String prompt) async {
    try {
      final result = await dataSource.enhancePrompt(prompt);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChainExperience>>> generateChainExperiences({
    required String prompt,
    required String location,
    required String date,
    required String totalTime,
    required List<String> interests,
  }) async {
    try {
      final result = await dataSource.generateChainExperiences(
        prompt: prompt,
        location: location,
        date: date,
        totalTime: totalTime,
        interests: interests,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}