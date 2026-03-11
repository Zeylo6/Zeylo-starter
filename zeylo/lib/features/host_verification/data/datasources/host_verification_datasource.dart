import 'dart:io';

abstract class HostVerificationDatasource {
  Future<void> submitVerificationRequest({
    required String uid,
    required Map<String, dynamic> data,
    required File nicFile,
    File? passportFile,
    File? driverLicenseFile,
  });

  Future<Map<String, dynamic>?> getVerificationRequest(String uid);
}
