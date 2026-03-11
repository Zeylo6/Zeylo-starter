import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class HostVerificationState {
  final int currentStep;
  final String fullName;
  final DateTime? dateOfBirth;
  final File? nicFile;
  final File? passportFile;
  final File? driverLicenseFile;
  final bool isSubmitting;
  final String? error;
  final bool isSuccess;

  const HostVerificationState({
    this.currentStep = 0,
    this.fullName = '',
    this.dateOfBirth,
    this.nicFile,
    this.passportFile,
    this.driverLicenseFile,
    this.isSubmitting = false,
    this.error,
    this.isSuccess = false,
  });

  HostVerificationState copyWith({
    int? currentStep,
    String? fullName,
    DateTime? dateOfBirth,
    File? nicFile,
    File? passportFile,
    File? driverLicenseFile,
    bool? isSubmitting,
    String? error,
    bool? isSuccess,
  }) {
    return HostVerificationState(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nicFile: nicFile ?? this.nicFile,
      passportFile: passportFile ?? this.passportFile,
      driverLicenseFile: driverLicenseFile ?? this.driverLicenseFile,
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

  void updateDocuments({File? nic, File? passport, File? license}) {
    state = state.copyWith(
      nicFile: nic ?? state.nicFile,
      passportFile: passport ?? state.passportFile,
      driverLicenseFile: license ?? state.driverLicenseFile,
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
