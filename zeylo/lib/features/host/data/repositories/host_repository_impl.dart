import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/earnings_entity.dart';
import '../../domain/entities/host_stats_entity.dart';
import '../../domain/repositories/host_repository.dart';
import '../datasources/host_datasource.dart';

/// Implementation of HostRepository
class HostRepositoryImpl implements HostRepository {
  final HostDatasource _datasource;

  HostRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, HostStatsEntity>> getHostStats(String hostId) async {
    try {
      final stats = await _datasource.getHostStats(hostId);
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EarningsEntity>> getEarnings(String hostId) async {
    try {
      final earnings = await _datasource.getEarnings(hostId);
      return Right(earnings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getThisMonthEarnings(String hostId) async {
    try {
      final earnings = await _datasource.getThisMonthEarnings(hostId);
      return Right(earnings);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getEarningsTrend(String hostId) async {
    try {
      final trend = await _datasource.getEarningsTrend(hostId);
      return Right(trend);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
