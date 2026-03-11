import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';

/// Represents a host verification request
class HostVerificationEntity {
  /// User's ID
  final String uid;

  /// User's provided full name for verification
  final String fullName;

  /// User's date of birth
  final DateTime dateOfBirth;

  /// Mandatory National Identity Card image URL
  final String nicImageUrl;

  /// Optional Passport image URL
  final String? passportImageUrl;

  /// Optional Driver's License image URL
  final String? driverLicenseImageUrl;

  /// Current status of the verification request
  final HostVerificationStatus status;

  /// Timestamp when the request was submitted
  final DateTime submittedAt;

  /// Timestamp when the request was reviewed (approved/rejected)
  final DateTime? reviewedAt;

  /// Optional reason for rejection
  final String? rejectionReason;

  const HostVerificationEntity({
    required this.uid,
    required this.fullName,
    required this.dateOfBirth,
    required this.nicImageUrl,
    this.passportImageUrl,
    this.driverLicenseImageUrl,
    this.status = HostVerificationStatus.pending,
    required this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });
}
