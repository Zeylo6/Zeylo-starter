import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/chain/presentation/providers/chain_provider.dart';
import '../../data/datasources/mystery_datasource.dart';
import '../../data/repositories/mystery_repository_impl.dart';
import '../../domain/entities/mystery_entity.dart';
import '../../domain/repositories/mystery_repository.dart';
import '../../domain/usecases/create_mystery_usecase.dart';

/// Firebase Firestore provider
final firebaseFirestoreProvider = Provider((ref) {
  return FirebaseFirestore.instance;
});

/// Mystery data source provider
final mysteryDataSourceProvider = Provider((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final aiService = ref.watch(aiServiceProvider);
  return MysteryDataSourceImpl(firestore: firestore, aiService: aiService);
});

/// Mystery repository provider
final mysteryRepositoryProvider = Provider<MysteryRepository>((ref) {
  final dataSource = ref.watch(mysteryDataSourceProvider);
  return MysteryRepositoryImpl(dataSource: dataSource);
});

/// Create mystery use case provider
final createMysteryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(mysteryRepositoryProvider);
  return CreateMysteryUseCase(repository: repository);
});

/// State for mystery form
class MysteryFormState {
  final String location;
  final String date;
  final MysteryTimeOfDay time;
  final double budgetMin;
  final double budgetMax;
  final MysteryExperienceType experienceType;
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final String? teaserDescription;
  final String? vibe;
  final String? preparationNotes;

  const MysteryFormState({
    this.location = '',
    this.date = '',
    this.time = MysteryTimeOfDay.morning,
    this.budgetMin = 0.0,
    this.budgetMax = 50000.0,
    this.experienceType = MysteryExperienceType.surpriseMe,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.teaserDescription,
    this.vibe,
    this.preparationNotes,
  });

  MysteryFormState copyWith({
    String? location,
    String? date,
    MysteryTimeOfDay? time,
    double? budgetMin,
    double? budgetMax,
    MysteryExperienceType? experienceType,
    bool? isLoading,
    String? error,
    bool? isSuccess,
    String? teaserDescription,
    String? vibe,
    String? preparationNotes,
  }) {
    return MysteryFormState(
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      experienceType: experienceType ?? this.experienceType,
      isLoading: isLoading ?? this.isLoading,
      // Allow explicitly setting error to null
      error: isLoading == true ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
      teaserDescription: teaserDescription ?? this.teaserDescription,
      vibe: vibe ?? this.vibe,
      preparationNotes: preparationNotes ?? this.preparationNotes,
    );
  }
}

/// Mystery form state notifier
class MysteryFormNotifier extends StateNotifier<MysteryFormState> {
  final CreateMysteryUseCase createMysteryUseCase;
  final String userId;

  MysteryFormNotifier({
    required this.createMysteryUseCase,
    required this.userId,
  }) : super(const MysteryFormState());

  void setLocation(String location) =>
      state = state.copyWith(location: location);

  void setDate(String date) => state = state.copyWith(date: date);

  void setTime(MysteryTimeOfDay time) => state = state.copyWith(time: time);

  void setBudgetMin(double budgetMin) =>
      state = state.copyWith(budgetMin: budgetMin);

  void setBudgetMax(double budgetMax) =>
      state = state.copyWith(budgetMax: budgetMax);

  void setExperienceType(MysteryExperienceType experienceType) =>
      state = state.copyWith(experienceType: experienceType);

  void clearError() => state = state.copyWith(error: null);

  Future<void> submitForm() async {
    // Clear previous error and set loading
    state = MysteryFormState(
      location: state.location,
      date: state.date,
      time: state.time,
      budgetMin: state.budgetMin,
      budgetMax: state.budgetMax,
      experienceType: state.experienceType,
      isLoading: true,
      error: null,
      isSuccess: false,
    );

    // Validate
    if (state.location.trim().isEmpty) {
      state = state.copyWith(
          isLoading: false, error: 'Please enter a location');
      return;
    }
    if (state.date.isEmpty) {
      state = state.copyWith(
          isLoading: false, error: 'Please select a date');
      return;
    }
    if (state.budgetMin >= state.budgetMax) {
      state = state.copyWith(
          isLoading: false,
          error: 'Minimum budget must be less than maximum');
      return;
    }

    final params = CreateMysteryParams(
      userId: userId,
      location: state.location,
      date: state.date,
      time: state.time,
      budgetMin: state.budgetMin,
      budgetMax: state.budgetMax,
      experienceType: state.experienceType,
    );

    final result = await createMysteryUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          error: failure.message,
        );
      },
      (mystery) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          error: null,
          teaserDescription: mystery.teaserDescription,
          vibe: mystery.vibe,
          preparationNotes: mystery.preparationNotes,
        );
      },
    );
  }
}

/// Mystery form state provider
final mysteryFormProvider =
    StateNotifierProvider.family<MysteryFormNotifier, MysteryFormState, String>(
  (ref, userId) {
    final useCase = ref.watch(createMysteryUseCaseProvider);
    return MysteryFormNotifier(
      createMysteryUseCase: useCase,
      userId: userId,
    );
  },
);

/// Mysteries list provider
final mysteriesProvider = FutureProvider.family(
  (ref, String userId) async {
    final repository = ref.watch(mysteryRepositoryProvider);
    final result = await repository.getMysteries(userId);
    return result.fold(
      (failure) => <MysteryEntity>[],
      (mysteries) => mysteries,
    );
  },
);

/// Single mystery provider
final mysteryDetailProvider = FutureProvider.family(
  (ref, String mysteryId) async {
    final repository = ref.watch(mysteryRepositoryProvider);
    final result = await repository.getMysteryById(mysteryId);
    return result.fold(
      (failure) => null,
      (mystery) => mystery,
    );
  },
);

/// Reveal mystery state
class RevealMysteryState {
  final bool isLoading;
  final String? error;

  const RevealMysteryState({this.isLoading = false, this.error});

  RevealMysteryState copyWith({bool? isLoading, String? error}) {
    return RevealMysteryState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Reveal mystery notifier
class RevealMysteryNotifier extends StateNotifier<RevealMysteryState> {
  final MysteryRepository repository;

  RevealMysteryNotifier({required this.repository})
      : super(const RevealMysteryState());

  Future<bool> acceptMystery(String mysteryId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await repository.acceptMystery(mysteryId);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> declineMystery(String mysteryId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await repository.declineMystery(mysteryId);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }
}

/// Reveal mystery provider
final revealMysteryProvider =
    StateNotifierProvider<RevealMysteryNotifier, RevealMysteryState>((ref) {
  final repository = ref.watch(mysteryRepositoryProvider);
  return RevealMysteryNotifier(repository: repository);
});