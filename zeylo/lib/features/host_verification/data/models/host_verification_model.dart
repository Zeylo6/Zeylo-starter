import '../../domain/entities/host_verification_entity.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';

/// Firestore model for HostVerificationEntity
class HostVerificationModel extends HostVerificationEntity {
  const HostVerificationModel({
    required super.uid,
    required super.fullName,
    required super.dateOfBirth,
    required super.nicImageUrl,
    super.passportImageUrl,
    super.driverLicenseImageUrl,
    super.status,
    required super.submittedAt,
    super.reviewedAt,
    super.rejectionReason,
  });

  /// Create model from Firestore document
  factory HostVerificationModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return HostVerificationModel(
      uid: uid,
      fullName: data['fullName'] as String? ?? '',
      dateOfBirth: data['dateOfBirth'] != null 
          ? (data['dateOfBirth'] as dynamic).toDate() as DateTime
          : DateTime.now(),
      nicImageUrl: data['nicImageUrl'] as String? ?? '',
      passportImageUrl: data['passportImageUrl'] as String?,
      driverLicenseImageUrl: data['driverLicenseImageUrl'] as String?,
      status: _parseStatus(data['status'] as String?),
      submittedAt: data['submittedAt'] != null
          ? (data['submittedAt'] as dynamic).toDate() as DateTime
          : DateTime.now(),
      reviewedAt: data['reviewedAt'] != null
          ? (data['reviewedAt'] as dynamic).toDate() as DateTime
          : null,
      rejectionReason: data['rejectionReason'] as String?,
    );
  }

  /// Convert model to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'nicImageUrl': nicImageUrl,
      'passportImageUrl': passportImageUrl,
      'driverLicenseImageUrl': driverLicenseImageUrl,
      'status': status.name,
      'submittedAt': submittedAt,
      'reviewedAt': reviewedAt,
      'rejectionReason': rejectionReason,
    };
  }

  static HostVerificationStatus _parseStatus(String? statusString) {
    if (statusString == null) return HostVerificationStatus.pending;
    return HostVerificationStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => HostVerificationStatus.pending,
    );
  }
}
