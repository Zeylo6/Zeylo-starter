import '../../../features/chain/domain/entities/chain_entity.dart';

/// Interface for AI services (e.g. Gemini, OpenAI)
abstract class AIService {
  /// Enhance a user prompt for better chain generation
  /// e.g. "relaxing day" -> "I'm looking for a peaceful itinerary starting with wellness or nature, followed by a quiet creative activity, and ending with a calm dinner."
  Future<String> enhancePrompt(String prompt);

  /// Generate a sequence of 3 experiences based on a prompt and location
  Future<List<ChainExperience>> generateChainExperiences(
      String prompt, String location, String date);
}
