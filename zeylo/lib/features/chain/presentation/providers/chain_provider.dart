import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/chain_datasource.dart';
import '../../data/repositories/chain_repository_impl.dart';
import '../../domain/entities/chain_entity.dart';
import '../../domain/repositories/chain_repository.dart';
import '../../domain/usecases/create_chain_usecase.dart';

/// Firebase Firestore provider
final firebaseFirestoreProvider = Provider((ref) {
  return FirebaseFirestore.instance;
});

/// Chain data source provider
final chainDataSourceProvider = Provider((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return ChainDataSourceImpl(firestore: firestore);
});

/// Chain repository provider
final chainRepositoryProvider = Provider<ChainRepository>((ref) {
  final dataSource = ref.watch(chainDataSourceProvider);
  return ChainRepositoryImpl(dataSource: dataSource);
});

/// Create chain use case provider
final createChainUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chainRepositoryProvider);
  return CreateChainUseCase(repository: repository);
});

/// State for chain form
class ChainFormState {
  final String name;
  final String description;
  final String destinationCity;
  final String date;
  final ChainDuration totalTime;
  final List<String> selectedInterests;
  final List<ChainExperience> experiences;
  final bool isLoading;
  final String? error;

  const ChainFormState({
    this.name = '',
    this.description = '',
    this.destinationCity = '',
    this.date = '',
    this.totalTime = ChainDuration.fullDay,
    this.selectedInterests = const [],
    this.experiences = const [],
    this.isLoading = false,
    this.error,
  });

  double get totalPrice =>
      experiences.fold(0.0, (sum, exp) => sum + exp.price);

  ChainFormState copyWith({
    String? name,
    String? description,
    String? destinationCity,
    String? date,
    ChainDuration? totalTime,
    List<String>? selectedInterests,
    List<ChainExperience>? experiences,
    bool? isLoading,
    String? error,
  }) {
    return ChainFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      destinationCity: destinationCity ?? this.destinationCity,
      date: date ?? this.date,
      totalTime: totalTime ?? this.totalTime,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      experiences: experiences ?? this.experiences,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Chain form state notifier
class ChainFormNotifier extends StateNotifier<ChainFormState> {
  final CreateChainUseCase createChainUseCase;
  final String userId;

  ChainFormNotifier({
    required this.createChainUseCase,
    required this.userId,
  }) : super(const ChainFormState());

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setDestinationCity(String city) {
    state = state.copyWith(destinationCity: city);
  }

  void setDate(String date) {
    state = state.copyWith(date: date);
  }

  void setTotalTime(ChainDuration totalTime) {
    state = state.copyWith(totalTime: totalTime);
  }

  void toggleInterest(String interest) {
    final interests = [...state.selectedInterests];
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
    state = state.copyWith(selectedInterests: interests);
  }

  void addExperience(ChainExperience experience) {
    final experiences = [...state.experiences, experience];
    state = state.copyWith(experiences: experiences);
  }

  void removeExperience(int index) {
    final experiences = [...state.experiences];
    if (index >= 0 && index < experiences.length) {
      experiences.removeAt(index);
    }
    state = state.copyWith(experiences: experiences);
  }

  void updateExperience(int index, ChainExperience experience) {
    final experiences = [...state.experiences];
    if (index >= 0 && index < experiences.length) {
      experiences[index] = experience;
    }
    state = state.copyWith(experiences: experiences);
  }

  Future<void> submitForm() async {
    state = state.copyWith(isLoading: true, error: null);

    // Validate form
    if (state.name.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Please enter a chain name',
      );
      return;
    }

    if (state.destinationCity.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Please select a destination',
      );
      return;
    }

    if (state.date.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Please select a date',
      );
      return;
    }

    if (state.experiences.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Please add at least one experience',
      );
      return;
    }

    final params = CreateChainParams(
      userId: userId,
      name: state.name,
      description: state.description,
      destinationCity: state.destinationCity,
      date: state.date,
      totalTime: state.totalTime,
      interests: state.selectedInterests,
      experiences: state.experiences,
    );

    final result = await createChainUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (chain) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Chain form state provider
final chainFormProvider =
    StateNotifierProvider.family<ChainFormNotifier, ChainFormState, String>(
  (ref, userId) {
    final useCase = ref.watch(createChainUseCaseProvider);
    return ChainFormNotifier(
      createChainUseCase: useCase,
      userId: userId,
    );
  },
);

/// Chains list provider
final chainsProvider = FutureProvider.family(
  (ref, String userId) async {
    final repository = ref.watch(chainRepositoryProvider);
    final result = await repository.getChainsByUserId(userId);
    return result.fold(
      (failure) => <ChainEntity>[],
      (chains) => chains,
    );
  },
);

/// Single chain provider
final chainDetailProvider = FutureProvider.family(
  (ref, String chainId) async {
    final repository = ref.watch(chainRepositoryProvider);
    final result = await repository.getChainById(chainId);
    return result.fold(
      (failure) => null,
      (chain) => chain,
    );
  },
);

/// Suggested chains provider
final suggestedChainsProvider = FutureProvider.family(
  (ref, SuggestedChainsParams params) async {
    final repository = ref.watch(chainRepositoryProvider);
    final result = await repository.getSuggestedChains(
      params.destinationCity,
      params.interests,
    );
    return result.fold(
      (failure) => <ChainEntity>[],
      (chains) => chains,
    );
  },
);

class SuggestedChainsParams {
  final String destinationCity;
  final List<String> interests;

  const SuggestedChainsParams({
    required this.destinationCity,
    required this.interests,
  });
}

/// Edit chain state
class EditChainState {
  final bool isLoading;
  final String? error;

  const EditChainState({
    this.isLoading = false,
    this.error,
  });

  EditChainState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return EditChainState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Edit chain notifier
class EditChainNotifier extends StateNotifier<EditChainState> {
  final ChainRepository repository;

  EditChainNotifier({required this.repository}) : super(const EditChainState());

  Future<bool> updateChain(ChainEntity chain) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.updateChain(chain);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> publishChain(String chainId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.publishChain(chainId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }
}

/// Edit chain provider
final editChainProvider =
    StateNotifierProvider<EditChainNotifier, EditChainState>((ref) {
  final repository = ref.watch(chainRepositoryProvider);
  return EditChainNotifier(repository: repository);
});
