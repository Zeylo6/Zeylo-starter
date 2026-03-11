import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mood_entity.dart';
import '../../../../core/services/ai_service.dart';
import '../../../chain/presentation/providers/chain_provider.dart' show aiServiceProvider;

/// State for mood selection
class MoodState {
  /// Selected mood
  final String? selectedMood;

  /// Mood description from user
  final String description;

  /// AI-enhanced description
  final String enhancedDescription;

  /// Whether AI enhancer is enabled
  final bool useAIEnhancer;

  /// Location preference
  final String? locationPreference;

  /// Budget preference
  final BudgetRange? budgetPreference;

  /// Time preference
  final TimePreference? timePreference;

  /// Whether currently processing
  final bool isLoading;

  /// Error message if any
  final String? error;

  const MoodState({
    this.selectedMood,
    this.description = '',
    this.enhancedDescription = '',
    this.useAIEnhancer = false,
    this.locationPreference,
    this.budgetPreference,
    this.timePreference,
    this.isLoading = false,
    this.error,
  });

  MoodState copyWith({
    String? selectedMood,
    String? description,
    String? enhancedDescription,
    bool? useAIEnhancer,
    String? locationPreference,
    BudgetRange? budgetPreference,
    TimePreference? timePreference,
    bool? isLoading,
    String? error,
  }) {
    return MoodState(
      selectedMood: selectedMood ?? this.selectedMood,
      description: description ?? this.description,
      enhancedDescription: enhancedDescription ?? this.enhancedDescription,
      useAIEnhancer: useAIEnhancer ?? this.useAIEnhancer,
      locationPreference: locationPreference ?? this.locationPreference,
      budgetPreference: budgetPreference ?? this.budgetPreference,
      timePreference: timePreference ?? this.timePreference,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Mood state notifier
class MoodNotifier extends StateNotifier<MoodState> {
  final AIService aiService;
  
  MoodNotifier({required this.aiService}) : super(const MoodState());

  /// Select a predefined mood
  void selectPredefinedMood(String mood) {
    state = state.copyWith(selectedMood: mood);
  }

  /// Set custom mood text
  void setCustomMood(String mood) {
    state = state.copyWith(selectedMood: mood);
  }

  /// Update mood description
  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// Toggle AI enhancer
  void toggleAIEnhancer() {
    state = state.copyWith(useAIEnhancer: !state.useAIEnhancer);
    if (state.useAIEnhancer && state.description.isNotEmpty) {
      _enhanceDescription();
    }
  }

  /// Enhance description with AI
  Future<void> _enhanceDescription() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final enhanced = await (aiService as dynamic).enhanceText(state.description, 'mood');
      state = state.copyWith(
        enhancedDescription: enhanced,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to enhance mood description',
        isLoading: false,
      );
    }
  }

  /// Set location preference
  void setLocationPreference(String location) {
    state = state.copyWith(locationPreference: location);
  }

  /// Set budget preference
  void setBudgetPreference(double min, double max) {
    state = state.copyWith(
      budgetPreference: BudgetRange(min: min, max: max),
    );
  }

  /// Set time preference
  void setTimePreference(TimePreference time) {
    state = state.copyWith(timePreference: time);
  }

  /// Reset mood state
  void reset() {
    state = const MoodState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Find matches for current mood
  Future<void> findMatches() async {
    if (state.selectedMood == null || state.selectedMood!.isEmpty) {
      state = state.copyWith(error: 'Please select or describe a mood');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Call find mood matches use case
      // For now, simulate delay
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to find matches: $e',
      );
    }
  }
}

/// Mood provider
final moodProvider =
    StateNotifierProvider<MoodNotifier, MoodState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return MoodNotifier(aiService: aiService);
});

/// Mood matches provider
final moodMatchesProvider = FutureProvider.family(
  (ref, MoodMatchesParams params) async {
    // TODO: Call find mood matches use case
    return <dynamic>[]; // Placeholder
  },
);

class MoodMatchesParams {
  final String mood;
  final String description;
  final String? location;
  final BudgetRange? budget;
  final TimePreference? timePreference;

  const MoodMatchesParams({
    required this.mood,
    required this.description,
    this.location,
    this.budget,
    this.timePreference,
  });
}

/// Recently selected moods provider
final recentMoodsProvider = StateNotifierProvider<
    RecentMoodsNotifier,
    List<String>>((ref) {
  return RecentMoodsNotifier();
});

class RecentMoodsNotifier extends StateNotifier<List<String>> {
  static const int maxRecentMoods = 5;

  RecentMoodsNotifier() : super([]);

  void addMood(String mood) {
    final moods = [mood, ...state];
    // Remove duplicates and limit to max
    final unique = moods.toSet().toList();
    state = unique.take(maxRecentMoods).toList();
  }

  void clearRecent() {
    state = [];
  }
}
