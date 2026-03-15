import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../datasources/host_verification_datasource.dart';

class HostVerificationDatasourceImpl implements HostVerificationDatasource {
  final FirebaseFirestore _firestore;

  HostVerificationDatasourceImpl(this._firestore);

  @override
  Future<void> submitVerificationRequest({
    required String uid,
    required Map<String, dynamic> data,
    required XFile nicFile,
    XFile? passportFile,
    XFile? driverLicenseFile,
  }) async {
    // 1. Upload Images to Firebase Storage
    final String nicUrl = await _uploadImage(uid, 'nic', nicFile);
    data['nicImageUrl'] = nicUrl;

    if (passportFile != null) {
      final String passportUrl = await _uploadImage(uid, 'passport', passportFile);
      data['passportImageUrl'] = passportUrl;
    }

    if (driverLicenseFile != null) {
      final String licenseUrl =
          await _uploadImage(uid, 'driver_license', driverLicenseFile);
      data['driverLicenseImageUrl'] = licenseUrl;
    }

    // 2. Save data to Firestore `host_verifications` collection
    await _firestore.collection('host_verifications').doc(uid).set(data);

    // 3. Update the user's `hostVerificationStatus` in the `users` collection to 'pending'
    await _firestore.collection('users').doc(uid).update({
      'hostVerificationStatus': 'pending',
    });
  }

  @override
  Future<Map<String, dynamic>?> getVerificationRequest(String uid) async {
    final doc =
        await _firestore.collection('host_verifications').doc(uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  Future<String> _uploadImage(String uid, String docType, XFile file) async {
    const cloudName = 'deukwmcoi';
    const uploadPreset = 'Zeylo_images';

    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final bytes = await file.readAsBytes();
      
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: file.name));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return jsonMap['secure_url'];
      } else {
        debugPrint('Cloudinary Error: ${jsonMap['error']['message']}');
        throw Exception('Cloudinary upload failed: ${jsonMap['error']['message']}');
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      rethrow;
    }
  }
}
