import 'dart:io';
import '../../domain/entities/host_verification_entity.dart';
import '../../domain/repositories/host_verification_repository.dart';
import '../datasources/host_verification_datasource.dart';
import '../models/host_verification_model.dart';

class HostVerificationRepositoryImpl implements HostVerificationRepository {
  final HostVerificationDatasource _datasource;

  HostVerificationRepositoryImpl(this._datasource);

  @override
  Future<void> submitVerificationRequest({
    required String uid,
    required String fullName,
    required DateTime dateOfBirth,
    required File nicFile,
    File? passportFile,
    File? driverLicenseFile,
  }) async {
    final data = {
      'uid': uid,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'status': 'pending',
      'submittedAt': DateTime.now(),
    };

    await _datasource.submitVerificationRequest(
      uid: uid,
      data: data,
      nicFile: nicFile,
      passportFile: passportFile,
      driverLicenseFile: driverLicenseFile,
    );
  }

  @override
  Future<HostVerificationEntity?> getVerificationRequest(String uid) async {
    final data = await _datasource.getVerificationRequest(uid);
    if (data != null) {
      return HostVerificationModel.fromFirestore(data, uid);
    }
    return null;
  }
}
