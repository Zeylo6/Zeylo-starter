import 'dart:convert';

import 'package:http/http.dart' as http;

/// Sends OTP emails via EmailJS REST API.
///
/// Configure these values via --dart-define:
/// - EMAILJS_SERVICE_ID
/// - EMAILJS_TEMPLATE_ID
/// - EMAILJS_PUBLIC_KEY
/// - EMAILJS_PRIVATE_KEY
class OtpEmailService {
  static const String _serviceId = String.fromEnvironment('EMAILJS_SERVICE_ID');
  static const String _templateId =
      String.fromEnvironment('EMAILJS_TEMPLATE_ID');
  static const String _publicKey = String.fromEnvironment('EMAILJS_PUBLIC_KEY');
  static const String _privateKey =
      String.fromEnvironment('EMAILJS_PRIVATE_KEY');

  bool get isConfigured =>
      _serviceId.isNotEmpty &&
      _templateId.isNotEmpty &&
      _publicKey.isNotEmpty &&
      _privateKey.isNotEmpty;

  Future<void> sendOtp({
    required String email,
    required String otpCode,
  }) async {
    if (!isConfigured) {
      throw Exception(
        'OTP email service is not configured. Add EMAILJS_* dart defines.',
      );
    }

    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'accessToken': _privateKey,
        'template_params': {
          'to_email': email,
          'otp_code': otpCode,
        },
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to send OTP email: ${response.body}');
    }
  }
}
