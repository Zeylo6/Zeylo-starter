import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/experience_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

/// Implementation of HomeRepository
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Experience>>> getFeaturedExperiences() async {
    try {
      final experiences = await remoteDataSource.getFeaturedExperiences();
      return Right(experiences.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Experience>>> getExperiencesByCategory(
    String category,
  ) async {
    try {
      final experiences =
          await remoteDataSource.getExperiencesByCategory(category);
      return Right(experiences.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Experience>>> searchExperiences(
    String query,
  ) async {
    try {
      final experiences = await remoteDataSource.searchExperiences(query);
      return Right(experiences.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Experience>>> getNearbyExperiences({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    try {
      final experiences = await remoteDataSource.getNearbyExperiences(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      return Right(experiences.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Experience>> getExperienceById(String id) async {
    try {
      final experience = await remoteDataSource.getExperienceById(id);
      return Right(experience.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Experience> getExperienceStream(String id) {
    return remoteDataSource.getExperienceStream(id).map((e) => e.toEntity());
  }

  @override
  Future<Either<Failure, List<Experience>>> getExperiencesByIds(List<String> ids) async {
    try {
      final experiences = await remoteDataSource.getExperiencesByIds(ids);
      return Right(experiences.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Experience>>> getAllExperiences() async {
    try {
      final experiences = await remoteDataSource.getAllExperiences();
      return Right(experiences.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
