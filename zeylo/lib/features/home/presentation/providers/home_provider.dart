import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/discovery/discovery_utils.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/experience_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_featured_experiences.dart';
import '../../domain/usecases/search_experiences.dart';
import '../../../../core/usecases/usecase.dart';

// Dependencies
final firebaseFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>(
  (ref) {
    final firestore = ref.watch(firebaseFirestoreProvider);
    return HomeRemoteDataSourceImpl(firestore);
  },
);

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) {
    final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
    return HomeRepositoryImpl(remoteDataSource: remoteDataSource);
  },
);

// Use Cases
final getFeaturedExperiencesUseCaseProvider = Provider<GetFeaturedExperiences>(
  (ref) {
    final repository = ref.watch(homeRepositoryProvider);
    return GetFeaturedExperiences(repository);
  },
);

final getCategoriesUseCaseProvider = Provider<GetCategories>(
  (ref) {
    final repository = ref.watch(homeRepositoryProvider);
    return GetCategories(repository);
  },
);

final searchExperiencesUseCaseProvider = Provider<SearchExperiences>(
  (ref) {
    final repository = ref.watch(homeRepositoryProvider);
    return SearchExperiences(repository);
  },
);

// State Providers
final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final selectedRatingProvider = StateProvider<double?>((ref) => null);

final priceRangeProvider = StateProvider<RangeValues>((ref) {
  return const RangeValues(0, 10000);
});

final discoverySortModeProvider =
    StateProvider<DiscoverySortMode>((ref) => DiscoverySortMode.relevance);

// Future Providers
final featuredExperiencesProvider =
    FutureProvider<List<Experience>>((ref) async {
  final useCase = ref.watch(getFeaturedExperiencesUseCaseProvider);
  final result = await useCase.call(NoParams());

  return result.fold(
    (failure) => throw Exception(failure.message),
    (experiences) => experiences,
  );
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  final result = await useCase.call(NoParams());

  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
});

final experiencesByFilterProvider =
    FutureProvider<List<Experience>>((ref) async {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedRating = ref.watch(selectedRatingProvider);
  final priceRange = ref.watch(priceRangeProvider);
  final sortMode = ref.watch(discoverySortModeProvider);

  final repository = ref.watch(homeRepositoryProvider);

  late final List<Experience> baseResults;

  if (searchQuery.isNotEmpty) {
    final result = await repository.searchExperiences(searchQuery);
    baseResults = result.fold(
      (failure) => throw Exception(failure.message),
      (experiences) => experiences,
    );
  } else if (selectedCategory != null && selectedCategory.isNotEmpty) {
    final result = await repository.getExperiencesByCategory(selectedCategory);
    baseResults = result.fold(
      (failure) => throw Exception(failure.message),
      (experiences) => experiences,
    );
  } else {
    final result = await repository.getFeaturedExperiences();
    baseResults = result.fold(
      (failure) => throw Exception(failure.message),
      (experiences) => experiences,
    );
  }

  final sorted = DiscoveryUtils.rankExperiences(
    experiences: baseResults,
    sortMode: sortMode,
    query: searchQuery,
    preferredCategory: selectedCategory,
    minPrice: priceRange.start,
    maxPrice: priceRange.end,
    userLatitude: null,
    userLongitude: null,
  );

  final ratingFiltered = selectedRating == null
      ? sorted
      : sorted
          .where((experience) => experience.averageRating >= selectedRating)
          .toList();

  return ratingFiltered;
});

final experienceDetailProvider =
    FutureProvider.family<Experience, String>((ref, experienceId) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getExperienceById(experienceId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (experience) => experience,
  );
});

// Using Flutter's built-in RangeValues from material.dart
