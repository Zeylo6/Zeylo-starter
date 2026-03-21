import '../../../features/chain/domain/entities/chain_entity.dart';

/// Interface for AI services (e.g. Gemini, OpenAI)
abstract class AIService {
  /// Enhance a user prompt for better chain generation
  /// e.g. "relaxing day" -> "I'm looking for a peaceful itinerary starting with wellness or nature, followed by a quiet creative activity, and ending with a calm dinner."
  Future<String> enhancePrompt(String prompt);

  /// Enhance text explicitly with a contextual prompt flag
  Future<String> enhanceText(String prompt, String contextType);

  /// Generate a sequence of 3 experiences based on a prompt and location
  Future<List<ChainExperience>> generateChainExperiences(
      String prompt, String location, String date);

  /// Generate a mystery surprise itinerary
  /// Generate a mystery surprise itinerary
  Future<Map<String, dynamic>> generateSurprise(Map<String, dynamic> preferences);

  /// Matches preferences to a real experience and creates a booking via Backend
  Future<Map<String, dynamic>> matchAndBookMystery(Map<String, dynamic> payload);
}
