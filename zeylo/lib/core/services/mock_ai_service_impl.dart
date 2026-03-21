import '../../features/chain/domain/entities/chain_entity.dart';
import 'ai_service.dart';

/// A mock implementation of the AIService for local testing
class MockAIServiceImpl implements AIService {
  @override
  Future<String> enhancePrompt(String prompt) async {
    await Future.delayed(const Duration(seconds: 1));

    final lowerPrompt = prompt.toLowerCase();

    if (lowerPrompt.contains('relax')) {
      return "I'm looking for a peaceful itinerary starting with wellness or nature, followed by a quiet creative activity, and ending with a calm dinner.";
    } else if (lowerPrompt.contains('energetic') ||
        lowerPrompt.contains('active')) {
      return "I want a high-energy day! Let's start with a rigorous outdoor adventure, move into exploring vibrant local culture on foot, and finish with exciting nightlife.";
    } else if (lowerPrompt.contains('food') || lowerPrompt.contains('eat')) {
      return "I'm a foodie looking for the ultimate culinary journey. I want to start with a local market tour and breakfast, follow it up with a cooking class for lunch, and end with an exquisite fine dining experience.";
    }

    return "Enhanced version of: $prompt";
  }

  @override
  Future<String> enhanceText(String prompt, String contextType) async {
    await Future.delayed(const Duration(seconds: 1));
    return "[$contextType enhanced] $prompt";
  }

  @override
  Future<List<ChainExperience>> generateChainExperiences({
    required String prompt,
    required String location,
    required String date,
    required String totalTime,
    required List<String> interests,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    return [
      ChainExperience(
        experienceId: 'mock-exp-1',
        title: 'Morning Nature Walk',
        startTime: '08:00',
        endTime: '10:00',
        duration: 2.0,
        price: 2500,
        isOvernight: false,
        imageUrl: '',
        category: 'Nature',
      ),
      ChainExperience(
        experienceId: 'mock-exp-2',
        title: 'Local Lunch Experience',
        startTime: '10:30',
        endTime: '12:00',
        duration: 1.5,
        price: 4000,
        isOvernight: false,
        imageUrl: '',
        category: 'Food Tours',
      ),
      ChainExperience(
        experienceId: 'mock-exp-3',
        title: 'Cultural Village Visit',
        startTime: '13:00',
        endTime: '15:00',
        duration: 2.0,
        price: 3500,
        isOvernight: false,
        imageUrl: '',
        category: 'Walking Tours',
      ),
    ];
  }

  @override
  Future<Map<String, dynamic>> generateSurprise(
    Map<String, dynamic> preferences,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'title': 'A Mocked Surprise',
      'teaserDescription': 'A test teaser',
      'category': 'Adventure',
      'vibe': 'Chill',
      'preparationNotes': 'None required',
    };
  }

  @override
  Future<Map<String, dynamic>> matchAndBookMystery(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'matched': true,
      'bookingId': 'mock-booking-id',
      'teaserDescription': 'A mocked teaser description',
      'vibe': 'Exciting Mock',
      'preparationNotes': 'Mock preparation notes',
    };
  }
}