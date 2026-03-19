import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/earnings_entity.dart';
import '../entities/host_stats_entity.dart';

/// Abstract repository for host operations
abstract class HostRepository {
  /// Get host statistics
  Future<Either<Failure, HostStatsEntity>> getHostStats(String hostId);

  /// Get host earnings
  Future<Either<Failure, EarningsEntity>> getEarnings(String hostId);

  /// Get this month's earnings
  Future<Either<Failure, double>> getThisMonthEarnings(String hostId);

  /// Get trend percentage
  Future<Either<Failure, double>> getEarningsTrend(String hostId);

  /// Watch host statistics reactively
  Stream<Either<Failure, HostStatsEntity>> watchHostStats(String hostId);

  /// Watch this month's earnings reactively
  Stream<Either<Failure, double>> watchThisMonthEarnings(String hostId);
}
