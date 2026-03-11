import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/chain/domain/entities/chain_entity.dart';
import '../config/app_config.dart';
import 'ai_service.dart';

/// Concrete implementation of [AIService] that securely offloads Gemini prompts
/// to our custom Node.js backend to protect API keys.
class ApiAiService implements AIService {
  static String get baseUrl => '${AppConfig.apiBase}/ai';

  Future<Map<String, String>> _getSecurityHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to use AI features.');
    }
    final idToken = await user.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };
  }

  /// Pings the backend to enhance short strings safely.
  /// Valid contexts: 'mood', 'host_experience', 'business_review'
  Future<String> enhanceText(String prompt, String contextType) async {
    try {
      final headers = await _getSecurityHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/enhance'),
        headers: headers,
        body: json.encode({
          'text': prompt,
          'context': contextType,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['enhancedText'] as String;
      } else {
        throw Exception(
            'AI enhance failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('ApiAiService Enhance Error: $e');
      throw Exception('Failed to communicate with AI Server.');
    }
  }

  /// Legacy override. We reroute traditional enhancePrompt to general enhancement context.
  @override
  Future<String> enhancePrompt(String prompt) async {
    return enhanceText(prompt, 'general');
  }

  @override
  Future<List<ChainExperience>> generateChainExperiences(
      String prompt, String location, String date) async {
    try {
      final headers = await _getSecurityHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/chain/generate'),
        headers: headers,
        body: json.encode({
          'prompt': prompt,
          'location': location,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final chainArray = data['data']['chain'] as List<dynamic>;

        return chainArray
            .map((item) => ChainExperience(
                  experienceId: item['experienceId']?.toString() ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  title: item['title']?.toString() ?? 'Generated Experience',
                  startTime: item['startTime']?.toString() ?? '10:00',
                  endTime: item['endTime']?.toString() ?? '12:00',
                  duration:
                      double.tryParse(item['duration']?.toString() ?? '2.0') ??
                          2.0,
                  price:
                      double.tryParse(item['price']?.toString() ?? '0') ?? 0.0,
                  isOvernight: item['isOvernight'] == true ||
                      item['isOvernight'] == 'true',
                ))
            .toList();
      } else {
        throw Exception(
            'AI Chain generation failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('ApiAiService Chain Error: $e');
      throw Exception('Failed to generate chain from Server.');
    }
  }

  /// Pings the backend to generate a Mystery Surprise.
  Future<Map<String, dynamic>> generateSurprise(
      Map<String, dynamic> preferences) async {
    try {
      final headers = await _getSecurityHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/mystery/generate'),
        headers: headers,
        body: json.encode({
          'preferences': preferences,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['mystery'] as Map<String, dynamic>;
      } else {
        throw Exception(
            'AI Mystery generation failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('ApiAiService Surprise Error: $e');
      throw Exception('Failed to communicate with AI Server.');
    }
  }
}
