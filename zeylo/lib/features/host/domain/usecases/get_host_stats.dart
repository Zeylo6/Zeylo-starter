import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/host_stats_entity.dart';
import '../repositories/host_repository.dart';

/// Use case for getting host stats
class GetHostStatsUseCase {
  final HostRepository repository;

  GetHostStatsUseCase(this.repository);

  Future<Either<Failure, HostStatsEntity>> call(String hostId) async {
    return await repository.getHostStats(hostId);
  }
}
