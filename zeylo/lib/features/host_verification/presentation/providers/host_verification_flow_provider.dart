import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class HostVerificationState {
  final int currentStep;
  final String fullName;
  final DateTime? dateOfBirth;
  final XFile? nicFile;
  final Uint8List? nicBytes;
  final XFile? passportFile;
  final Uint8List? passportBytes;
  final XFile? driverLicenseFile;
  final Uint8List? driverLicenseBytes;
  final bool isSubmitting;
  final String? error;
  final bool isSuccess;

  const HostVerificationState({
    this.currentStep = 0,
    this.fullName = '',
    this.dateOfBirth,
    this.nicFile,
    this.nicBytes,
    this.passportFile,
    this.passportBytes,
    this.driverLicenseFile,
    this.driverLicenseBytes,
    this.isSubmitting = false,
    this.error,
    this.isSuccess = false,
  });

  HostVerificationState copyWith({
    int? currentStep,
    String? fullName,
    DateTime? dateOfBirth,
    XFile? nicFile,
    Uint8List? nicBytes,
    XFile? passportFile,
    Uint8List? passportBytes,
    XFile? driverLicenseFile,
    Uint8List? driverLicenseBytes,
    bool? isSubmitting,
    String? error,
    bool? isSuccess,
  }) {
    return HostVerificationState(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nicFile: nicFile ?? this.nicFile,
      nicBytes: nicBytes ?? this.nicBytes,
      passportFile: passportFile ?? this.passportFile,
      passportBytes: passportBytes ?? this.passportBytes,
      driverLicenseFile: driverLicenseFile ?? this.driverLicenseFile,
      driverLicenseBytes: driverLicenseBytes ?? this.driverLicenseBytes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class HostVerificationNotifier extends StateNotifier<HostVerificationState> {
  HostVerificationNotifier() : super(const HostVerificationState());

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updatePersonalDetails(String fullName, DateTime dateOfBirth) {
    state = state.copyWith(fullName: fullName, dateOfBirth: dateOfBirth);
  }

  void updateDocuments({
    XFile? nic, Uint8List? nicBytes,
    XFile? passport, Uint8List? passportBytes,
    XFile? license, Uint8List? licenseBytes,
  }) {
    state = state.copyWith(
      nicFile: nic ?? state.nicFile,
      nicBytes: nicBytes ?? state.nicBytes,
      passportFile: passport ?? state.passportFile,
      passportBytes: passportBytes ?? state.passportBytes,
      driverLicenseFile: license ?? state.driverLicenseFile,
      driverLicenseBytes: licenseBytes ?? state.driverLicenseBytes,
    );
  }

  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }

  void setError(String? error) {
    state = state.copyWith(error: error, isSubmitting: false);
  }

  void setSuccess() {
    state = state.copyWith(isSuccess: true, isSubmitting: false);
  }
}

final hostVerificationFlowProvider = StateNotifierProvider<HostVerificationNotifier, HostVerificationState>((ref) {
  return HostVerificationNotifier();
});
