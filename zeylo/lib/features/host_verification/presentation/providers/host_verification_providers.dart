import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/host_verification_datasource.dart';
import '../../data/datasources/host_verification_datasource_impl.dart';
import '../../domain/repositories/host_verification_repository.dart';
import '../../data/repositories/host_verification_repository_impl.dart';

final hostVerificationDatasourceProvider = Provider<HostVerificationDatasource>((ref) {
  return HostVerificationDatasourceImpl(
    FirebaseFirestore.instance,
  );
});

final hostVerificationRepositoryProvider = Provider<HostVerificationRepository>((ref) {
  final datasource = ref.watch(hostVerificationDatasourceProvider);
  return HostVerificationRepositoryImpl(datasource);
});

final hostVerificationStatusProvider = FutureProvider.family<String?, String>((ref, uid) async {
  final repository = ref.watch(hostVerificationRepositoryProvider);
  final request = await repository.getVerificationRequest(uid);
  return request?.status.name;
});
