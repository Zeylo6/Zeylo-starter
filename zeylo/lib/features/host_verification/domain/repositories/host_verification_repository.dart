import 'package:image_picker/image_picker.dart';
import '../entities/host_verification_entity.dart';

abstract class HostVerificationRepository {
  /// Submit a new host verification request
  /// 
  /// [uid] is the user ID
  /// [fullName] is the full name of the host
  /// [dateOfBirth] is the true date of birth
  /// [nicFile] is the mandatory National Identity Card image file
  /// [passportFile] is the optional Passport image file
  /// [driverLicenseFile] is the optional Driver's License image file
  Future<void> submitVerificationRequest({
    required String uid,
    required String fullName,
    required DateTime dateOfBirth,
    required XFile nicFile,
    XFile? passportFile,
    XFile? driverLicenseFile,
  });

  /// Check if the user has a pending or approved verification request
  Future<HostVerificationEntity?> getVerificationRequest(String uid);
}
