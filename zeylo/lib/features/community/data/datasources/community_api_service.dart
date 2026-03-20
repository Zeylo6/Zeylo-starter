import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/config/app_config.dart';

/// Service to communicate with the backend for community-related actions
/// like push notifications.
class CommunityApiService {
  static String get baseUrl => '${AppConfig.apiBase}/community';

  Future<Map<String, String>> _getSecurityHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {'Content-Type': 'application/json'};
    
    final idToken = await user.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };
  }

  /// Triggers a "like" notification on the backend
  Future<void> notifyLike({
    required String authorId,
    required String likerName,
    required String postId,
  }) async {
    try {
      final headers = await _getSecurityHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/notify-like'),
        headers: headers,
        body: json.encode({
          'authorId': authorId,
          'likerName': likerName,
          'postId': postId,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Backend Like Notification Failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('CommunityApiService notifyLike Error: $e');
    }
  }

  /// Triggers a "comment" notification on the backend
  Future<void> notifyComment({
    required String authorId,
    required String commenterName,
    required String postId,
    required String commentText,
  }) async {
    try {
      final headers = await _getSecurityHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/notify-comment'),
        headers: headers,
        body: json.encode({
          'authorId': authorId,
          'commenterName': commenterName,
          'postId': postId,
          'commentText': commentText,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Backend Comment Notification Failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('CommunityApiService notifyComment Error: $e');
    }
  }
}
