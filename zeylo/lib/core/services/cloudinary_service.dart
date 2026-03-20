import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A centralized service for uploading images to Cloudinary.
class CloudinaryService {
  static const String cloudName = 'deukwmcoi';
  static const String uploadPreset = 'Zeylo_images';

  /// Uploads an image file to Cloudinary and returns the secure URL.
  /// Returns [null] if the upload fails.
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return jsonMap['secure_url'] as String?;
      } else {
        debugPrint('Cloudinary Error: ${jsonMap['error']?['message'] ?? 'Unknown error'}');
        return null;
      }
    } catch (e) {
      debugPrint("Cloudinary Upload Exception: $e");
      return null;
    }
  }
}
