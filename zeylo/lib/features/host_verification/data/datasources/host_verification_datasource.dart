import 'package:image_picker/image_picker.dart';

abstract class HostVerificationDatasource {
  Future<void> submitVerificationRequest({
    required String uid,
    required Map<String, dynamic> data,
    required XFile nicFile,
    XFile? passportFile,
    XFile? driverLicenseFile,
  });

  Future<Map<String, dynamic>?> getVerificationRequest(String uid);
}
