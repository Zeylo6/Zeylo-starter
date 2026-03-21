import '../../features/chain/domain/entities/chain_entity.dart';

/// Interface for AI services (e.g. Gemini, OpenAI)
abstract class AIService {
  /// Enhance a user prompt for better chain generation
  Future<String> enhancePrompt(String prompt);

  /// Enhance text explicitly with a contextual prompt flag
  Future<String> enhanceText(String prompt, String contextType);

  /// Generate a sequence of real experiences based on user input
  Future<List<ChainExperience>> generateChainExperiences({
    required String prompt,
    required String location,
    required String date,
    required String totalTime,
    required List<String> interests,
  });

  /// Generate a mystery surprise itinerary
  Future<Map<String, dynamic>> generateSurprise(Map<String, dynamic> preferences);

  /// Match and book a mystery experience
  Future<Map<String, dynamic>> matchAndBookMystery(Map<String, dynamic> payload);
}