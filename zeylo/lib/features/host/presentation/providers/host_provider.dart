import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/host_datasource.dart';
import '../../data/repositories/host_repository_impl.dart';
import '../../domain/entities/earnings_entity.dart';
import '../../domain/entities/host_stats_entity.dart';
import '../../domain/repositories/host_repository.dart';
import '../../domain/usecases/get_host_stats.dart';

// Datasource provider
final hostDatasourceProvider = Provider((ref) {
  return HostFirestoreDatasource(FirebaseFirestore.instance);
});

// Repository provider
final hostRepositoryProvider = Provider<HostRepository>((ref) {
  final datasource = ref.watch(hostDatasourceProvider);
  return HostRepositoryImpl(datasource);
});

// Use case provider
final getHostStatsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(hostRepositoryProvider);
  return GetHostStatsUseCase(repository);
});

// Host stats provider
final hostStatsProvider = StreamProvider.family<HostStatsEntity, String>(
  (ref, hostId) {
    final repository = ref.watch(hostRepositoryProvider);
    return repository.watchHostStats(hostId).map((result) {
      return result.fold(
        (failure) => throw failure.message,
        (stats) => stats,
      );
    });
  },
);

// Host earnings provider
final hostEarningsProvider = FutureProvider.family<EarningsEntity, String>(
  (ref, hostId) async {
    final repository = ref.watch(hostRepositoryProvider);
    final result = await repository.getEarnings(hostId);
    return result.fold(
      (failure) => throw failure.message,
      (earnings) => earnings,
    );
  },
);

// This month earnings provider (Reactive)
final thisMonthEarningsProvider = StreamProvider.family<double, String>(
  (ref, hostId) {
    final repository = ref.watch(hostRepositoryProvider);
    return repository.watchThisMonthEarnings(hostId).map((result) {
      return result.fold(
        (failure) => 0.0,
        (earnings) => earnings,
      );
    });
  },
);

// Earnings trend provider
final earningsTrendProvider = FutureProvider.family<double, String>(
  (ref, hostId) async {
    final repository = ref.watch(hostRepositoryProvider);
    final result = await repository.getEarningsTrend(hostId);
    return result.fold(
      (failure) => throw failure.message,
      (trend) => trend,
    );
  },
);
