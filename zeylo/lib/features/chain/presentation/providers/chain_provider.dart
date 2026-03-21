import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/api_ai_service.dart';
import '../../data/datasources/chain_datasource.dart';
import '../../data/repositories/chain_repository_impl.dart';
import '../../domain/entities/chain_entity.dart';
import '../../domain/repositories/chain_repository.dart';
import '../../domain/usecases/create_chain_usecase.dart';
import '../../domain/usecases/enhance_chain_prompt_usecase.dart';
import '../../domain/usecases/generate_chain_experiences_usecase.dart';
import '../../../../features/booking/domain/usecases/create_booking_usecase.dart';
import '../../../../features/booking/presentation/providers/booking_provider.dart';
import '../../../../features/booking/domain/entities/booking_entity.dart';

final firebaseFirestoreProvider = Provider((ref) {
  return FirebaseFirestore.instance;
});

final aiServiceProvider = Provider<AIService>((ref) {
  return ApiAiService();
});

final chainDataSourceProvider = Provider((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final aiService = ref.watch(aiServiceProvider);
  return ChainDataSourceImpl(firestore: firestore, aiService: aiService);
});

final chainRepositoryProvider = Provider<ChainRepository>((ref) {
  final dataSource = ref.watch(chainDataSourceProvider);
  return ChainRepositoryImpl(dataSource: dataSource);
});

final createChainUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chainRepositoryProvider);
  return CreateChainUseCase(repository: repository);
});

final enhanceChainPromptUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chainRepositoryProvider);
  return EnhanceChainPromptUseCase(repository: repository);
});

final generateChainExperiencesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chainRepositoryProvider);
  return GenerateChainExperiencesUseCase(repository: repository);
});

class ChainFormState {
  final String name;
  final String description;
  final String destinationCity;
  final String date;
  final ChainDuration totalTime;
  final List<String> selectedInterests;
  final List<ChainExperience> experiences;
  final String prompt;
  final bool isEnhancing;
  final bool isGenerating;
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
    this.prompt = '',
    this.isEnhancing = false,
    this.isGenerating = false,
    this.isLoading = false,
    this.error,
  });

  double get totalPrice => experiences.fold(0.0, (sum, exp) => sum + exp.price);

  ChainFormState copyWith({
    String? name,
    String? description,
    String? destinationCity,
    String? date,
    ChainDuration? totalTime,
    List<String>? selectedInterests,
    List<ChainExperience>? experiences,
    String? prompt,
    bool? isEnhancing,
    bool? isGenerating,
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
      prompt: prompt ?? this.prompt,
      isEnhancing: isEnhancing ?? this.isEnhancing,
      isGenerating: isGenerating ?? this.isGenerating,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChainFormNotifier extends StateNotifier<ChainFormState> {
  final CreateChainUseCase createChainUseCase;
  final EnhanceChainPromptUseCase enhanceChainPromptUseCase;
  final GenerateChainExperiencesUseCase generateChainExperiencesUseCase;
  final CreateBookingUseCase createBookingUseCase;
  final String userId;

  ChainFormNotifier({
    required this.createChainUseCase,
    required this.enhanceChainPromptUseCase,
    required this.generateChainExperiencesUseCase,
    required this.createBookingUseCase,
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

  void setPrompt(String prompt) {
    state = state.copyWith(prompt: prompt);
  }

  Future<void> enhancePrompt() async {
    if (state.prompt.isEmpty) return;

    state = state.copyWith(
      isEnhancing: true,
      error: null,
    );

    final result = await enhanceChainPromptUseCase(state.prompt);

    result.fold(
      (failure) => state = state.copyWith(
        isEnhancing: false,
        error: failure.message,
      ),
      (enhanced) => state = state.copyWith(
        isEnhancing: false,
        prompt: enhanced,
        error: null,
      ),
    );
  }

  Future<void> generateExperiences() async {
    if (state.prompt.isEmpty) return;

    if (state.destinationCity.isEmpty) {
      state = state.copyWith(error: 'Please enter a destination first');
      return;
    }

    state = state.copyWith(
      isGenerating: true,
      error: null,
    );

    final params = GenerateChainExperiencesParams(
      prompt: state.prompt,
      location: state.destinationCity,
      date: state.date,
      totalTime: state.totalTime.name,
      interests: state.selectedInterests,
    );

    final result = await generateChainExperiencesUseCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        isGenerating: false,
        error: failure.message,
      ),
      (experiences) => state = state.copyWith(
        isGenerating: false,
        experiences: experiences,
        error: null,
      ),
    );
  }

  Future<void> submitForm() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

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
      (chain) async {
        // Create bookings for each experience in the chain
        try {
          DateTime experienceDate = DateTime.now();
          if (state.date.isNotEmpty) {
            final parts = state.date.split('/');
            if (parts.length == 3) {
              experienceDate = DateTime(int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
            }
          }

          for (final exp in state.experiences) {
            if (exp.hostId.isEmpty) continue;

            final booking = BookingEntity(
              id: '', // Will be generated by Firestore
              experienceId: exp.experienceId,
              experienceTitle: exp.title,
              experienceCoverImage: exp.imageUrl,
              userId: userId,
              hostId: exp.hostId,
              date: experienceDate,
              startTime: exp.startTime,
              guests: 1, // Default to 1 for chain bookings
              totalPrice: exp.price,
              status: 'pending',
              paymentStatus: 'pending',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              chainId: chain.id,
            );

            await createBookingUseCase.call(booking);
          }
        } catch (e) {
          print('Error generating chain bookings: $e');
        }

        state = state.copyWith(
          isLoading: false,
          error: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final chainFormProvider =
    StateNotifierProvider.family<ChainFormNotifier, ChainFormState, String>(
  (ref, userId) {
    final createUseCase = ref.watch(createChainUseCaseProvider);
    final enhanceUseCase = ref.watch(enhanceChainPromptUseCaseProvider);
    final generateUseCase = ref.watch(generateChainExperiencesUseCaseProvider);
    final createBookingUseCase = ref.watch(createBookingUseCaseProvider);

    return ChainFormNotifier(
      createChainUseCase: createUseCase,
      enhanceChainPromptUseCase: enhanceUseCase,
      generateChainExperiencesUseCase: generateUseCase,
      createBookingUseCase: createBookingUseCase,
      userId: userId,
    );
  },
);

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

class EditChainState {
  final bool isLoading;
  final String? error;

  const EditChainState({this.isLoading = false, this.error});

  EditChainState copyWith({bool? isLoading, String? error}) {
    return EditChainState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EditChainNotifier extends StateNotifier<EditChainState> {
  final ChainRepository repository;

  EditChainNotifier({required this.repository}) : super(const EditChainState());

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading, error: null);
  }

  Future<bool> updateChain(ChainEntity chain) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await repository.updateChain(chain);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, error: null);
        return true;
      },
    );
  }

  Future<bool> publishChain(String chainId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await repository.publishChain(chainId);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, error: null);
        return true;
      },
    );
  }
}

final editChainProvider = StateNotifierProvider<EditChainNotifier, EditChainState>((ref) {
  final repository = ref.watch(chainRepositoryProvider);
  return EditChainNotifier(repository: repository);
});