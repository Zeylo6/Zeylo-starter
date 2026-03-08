import 'dart:math';
import '../../../features/chain/domain/entities/chain_entity.dart';
import 'ai_service.dart';

/// A mock implementation of the AIService for local testing
class MockAIServiceImpl implements AIService {
  final _random = Random();

  String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString() +
      _random.nextInt(1000).toString();

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

    return "I'm looking for an engaging and well-rounded day that perfectly captures the spirit of the destination, balancing exploration, culture, and relaxation.";
  }

  @override
  Future<List<ChainExperience>> generateChainExperiences(
      String prompt, String location, String date) async {
    // Simulate network delay of thinking/generating
    await Future.delayed(const Duration(seconds: 2));

    final isRelaxing = prompt.toLowerCase().contains('peaceful') ||
        prompt.toLowerCase().contains('relax');
    final isFood = prompt.toLowerCase().contains('culinary') ||
        prompt.toLowerCase().contains('food');

    if (isRelaxing) {
      return [
        ChainExperience(
          experienceId: _generateId(),
          title: 'Morning Yoga by the River',
          startTime: '08:00',
          endTime: '09:30',
          duration: 1.5,
          price: 25.0,
          isOvernight: false,
        ),
        ChainExperience(
          experienceId: _generateId(),
          title: 'Pottery Painting Masterclass',
          startTime: '11:00',
          endTime: '13:00',
          duration: 2.0,
          price: 45.0,
          isOvernight: false,
        ),
        ChainExperience(
          experienceId: _generateId(),
          title: 'Sunset Acoustic Dinner',
          startTime: '18:00',
          endTime: '20:30',
          duration: 2.5,
          price: 85.0,
          isOvernight: false,
        ),
      ];
    } else if (isFood) {
      return [
        ChainExperience(
          experienceId: _generateId(),
          title: 'Secret Local Market Tour',
          startTime: '09:00',
          endTime: '11:00',
          duration: 2.0,
          price: 35.0,
          isOvernight: false,
        ),
        ChainExperience(
          experienceId: _generateId(),
          title: 'Authentic Pasta Making Class',
          startTime: '13:00',
          endTime: '16:00',
          duration: 3.0,
          price: 120.0,
          isOvernight: false,
        ),
        ChainExperience(
          experienceId: _generateId(),
          title: 'Michelin Star Wine & Dine',
          startTime: '19:00',
          endTime: '22:00',
          duration: 3.0,
          price: 250.0,
          isOvernight: false,
        ),
      ];
    }

    // Default/Generic Chain
    return [
      ChainExperience(
        experienceId: _generateId(),
        title: 'Morning Historic City Walk',
        startTime: '09:00',
        endTime: '11:30',
        duration: 2.5,
        price: 40.0,
        isOvernight: false,
      ),
      ChainExperience(
        experienceId: _generateId(),
        title: 'Lunch & Local Coffee Tasting',
        startTime: '12:30',
        endTime: '14:00',
        duration: 1.5,
        price: 30.0,
        isOvernight: false,
      ),
      ChainExperience(
        experienceId: _generateId(),
        title: 'Evening Rooftop Drinks',
        startTime: '18:30',
        endTime: '20:30',
        duration: 2.0,
        price: 55.0,
        isOvernight: false,
      ),
    ];
  }
}
