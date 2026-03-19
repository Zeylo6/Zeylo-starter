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

// Stream Providers
final featuredExperiencesProvider = StreamProvider<List<Experience>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.watchFeaturedExperiences();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  final result = await useCase.call(NoParams());

  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) {
      // Prepend 'All' category
      final allCategory = Category(
        id: 'all',
        name: 'All',
        icon: 'assets/icons/all.svg',
        imageUrl: '',
        order: 0,
        isActive: true,
      );
      return [allCategory, ...categories];
    },
  );
});

final experiencesByFilterProvider = StreamProvider<List<Experience>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedRating = ref.watch(selectedRatingProvider);
  final priceRange = ref.watch(priceRangeProvider);
  final sortMode = ref.watch(discoverySortModeProvider);

  final repository = ref.watch(homeRepositoryProvider);

  Stream<List<Experience>> baseStream;

  if (searchQuery.isNotEmpty) {
    // Search is still Future-based in repository, convert to stream for consistency
    baseStream = Stream.fromFuture(repository.searchExperiences(searchQuery).then(
          (result) => result.fold(
            (failure) => throw Exception(failure.message),
            (experiences) => experiences,
          ),
        ));
  } else if (selectedCategory != null &&
      selectedCategory.isNotEmpty &&
      selectedCategory != 'All') {
    baseStream = repository.watchExperiencesByCategory(selectedCategory);
  } else {
    baseStream = repository.watchFeaturedExperiences();
  }

  return baseStream.map((experiences) {
    final sorted = DiscoveryUtils.rankExperiences(
      experiences: experiences,
      sortMode: sortMode,
      query: searchQuery,
      preferredCategory: selectedCategory,
      minPrice: priceRange.start,
      maxPrice: priceRange.end,
      userLatitude: null,
      userLongitude: null,
    );

    return selectedRating == null
        ? sorted
        : sorted
            .where((experience) => experience.averageRating >= selectedRating)
            .toList();
  });
});

final experienceDetailProvider =
    StreamProvider.family<Experience, String>((ref, experienceId) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getExperienceStream(experienceId);
});

// Using Flutter's built-in RangeValues from material.dart
