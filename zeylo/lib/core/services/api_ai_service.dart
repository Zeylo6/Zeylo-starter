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
          'AI enhance failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('ApiAiService Enhance Error: $e');
      rethrow;
    }
  }

  @override
  Future<String> enhancePrompt(String prompt) async {
    return enhanceText(prompt, 'general');
  }

  @override
  Future<List<ChainExperience>> generateChainExperiences({
    required String prompt,
    required String location,
    required String date,
    required String totalTime,
    required List<String> interests,
  }) async {
    try {
      final headers = await _getSecurityHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/chain/generate'),
        headers: headers,
        body: json.encode({
          'prompt': prompt,
          'location': location,
          'date': date,
          'totalTime': totalTime,
          'interests': interests,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final chainArray = data['data']['chain'] as List<dynamic>;

        return chainArray.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return ChainExperience(
            experienceId: map['experienceId']?.toString() ?? '',
            title: map['title']?.toString() ?? 'Generated Experience',
            startTime: map['startTime']?.toString() ?? '10:00',
            endTime: map['endTime']?.toString() ?? '12:00',
            duration: double.tryParse(map['duration']?.toString() ?? '0') ?? 0,
            price: double.tryParse(map['price']?.toString() ?? '0') ?? 0,
            isOvernight: map['isOvernight'] == true,
            imageUrl: map['imageUrl']?.toString() ?? '',
            category: map['category']?.toString() ?? '',
            hostId: map['hostId']?.toString() ?? '',
          );
        }).toList();
      } else {
        throw Exception(
          'AI Chain generation failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('ApiAiService Chain Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateSurprise(
    Map<String, dynamic> preferences,
  ) async {
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
          'AI Mystery generation failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('ApiAiService Surprise Error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> matchAndBookMystery(Map<String, dynamic> payload) async {
    try {
      final headers = await _getSecurityHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/mystery/match-book'),
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          'AI Mystery Match failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('ApiAiService matchAndBook Error: $e');
      rethrow;
    }
  }
}