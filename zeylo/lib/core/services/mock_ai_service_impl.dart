import '../../../features/chain/domain/entities/chain_entity.dart';
import 'ai_service.dart';

/// A mock implementation of the AIService for local testing
/// Returns predefined responses instead of calling real AI APIs
class MockAIServiceImpl implements AIService {
  @override
  Future<String> enhancePrompt(String prompt) async {
    // Simulate network delay
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
  Future<List<ChainExperience>> generateChainExperiences(
      String prompt, String location, String date) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final lowerPrompt = prompt.toLowerCase();

    if (lowerPrompt.contains('relax')) {
      return [
        ChainExperience(
          experienceId: _generateId(),
          title: 'Morning Yoga by the Beach',
          startTime: '07:00',
          endTime: '08:30',
          duration: 1.5,
          price: 25.0,
          isOvernight: false,
        ),
        ChainExperience(
          experienceId: _generateId(),
          title: 'Pottery Workshop',
          startTime: '11:00',
          endTime: '13:00',
          duration: 2.0,
          price: 45.0,
          isOvernight: false,
        ),
        ChainExperience(
          experienceId: _generateId(),
          title: 'Sunset Meditation',
          startTime: '17:30',
          endTime: '18:30',
          duration: 1.0,
          price: 15.0,
          isOvernight: false,
        ),
      ];
    } else if (lowerPrompt.contains('energetic')) {
      return [
        ChainExperience(
          experienceId: _generateId(),
          title: 'Mountain Bike Trail Match',
          startTime: '08:00',
          endTime: '11:00',
          duration: 3.0,
          price: 55.0,
          isOvernight: false,
        ),
        ChainExperience(
          experienceId: _generateId(),
          title: 'Street Art Walking Tour',
          startTime: '14:00',
          endTime: '16:00',
          duration: 2.0,
          price: 20.0,
          isOvernight: false,
        ),
        ChainExperience(
          experienceId: _generateId(),
          title: 'Live Music Bar Crawl',
          startTime: '20:00',
          endTime: '23:30',
          duration: 3.5,
          price: 40.0,
          isOvernight: false,
        ),
      ];
    }

    // Default response
    return [
      ChainExperience(
        experienceId: _generateId(),
        title: 'Morning Coffee Tasting',
        startTime: '09:00',
        endTime: '10:30',
        duration: 1.5,
        price: 30.0,
        isOvernight: false,
      ),
      ChainExperience(
        experienceId: _generateId(),
        title: 'Local Art Museum Pass',
        startTime: '11:30',
        endTime: '14:00',
        duration: 2.5,
        price: 25.0,
        isOvernight: false,
      ),
      ChainExperience(
        experienceId: _generateId(),
        title: 'Sunset Harbor Cruise',
        startTime: '17:00',
        endTime: '19:00',
        duration: 2.0,
        price: 65.0,
        isOvernight: false,
      ),
    ];
  }

  @override
  Future<Map<String, dynamic>> generateSurprise(Map<String, dynamic> preferences) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      "title": "A Mocked Surprise",
      "teaserDescription": "A test teaser",
      "category": "Adventure",
      "vibe": "Chill",
      "preparationNotes": "None required"
    };
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (DateTime.now().microsecond).toString();
  }
}
