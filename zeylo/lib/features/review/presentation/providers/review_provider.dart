import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/review_datasource.dart';
import '../../data/datasources/review_datasource_impl.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';

final reviewDatasourceProvider = Provider<ReviewDatasource>((ref) {
  return ReviewDatasourceImpl(FirebaseFirestore.instance);
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final datasource = ref.watch(reviewDatasourceProvider);
  return ReviewRepositoryImpl(datasource);
});

final experienceReviewsProvider = FutureProvider.family<List<ReviewEntity>, String>((ref, experienceId) async {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.getReviewsForExperience(experienceId);
});
