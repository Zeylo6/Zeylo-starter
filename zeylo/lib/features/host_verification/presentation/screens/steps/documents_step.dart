import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../providers/host_verification_flow_provider.dart';
import '../../providers/host_verification_providers.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class HostVerificationDocumentsScreen extends ConsumerStatefulWidget {
  const HostVerificationDocumentsScreen({super.key});

  @override
  ConsumerState<HostVerificationDocumentsScreen> createState() => _HostVerificationDocumentsScreenState();
}

class _HostVerificationDocumentsScreenState extends ConsumerState<HostVerificationDocumentsScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (image != null) {
      final notifier = ref.read(hostVerificationFlowProvider.notifier);
      
      switch (type) {
        case 'nic':
          notifier.updateDocuments(nic: image);
          break;
        case 'passport':
          notifier.updateDocuments(passport: image);
          break;
        case 'license':
          notifier.updateDocuments(license: image);
          break;
      }
    }
  }

  Future<void> _submitVerification() async {
    final state = ref.read(hostVerificationFlowProvider);
    final user = ref.read(currentUserProvider).value;
    
    if (user == null || state.nicFile == null || state.dateOfBirth == null) return;

    final notifier = ref.read(hostVerificationFlowProvider.notifier);
    notifier.setSubmitting(true);

    try {
      final repository = ref.read(hostVerificationRepositoryProvider);
      await repository.submitVerificationRequest(
        uid: user.uid,
        fullName: state.fullName,
        dateOfBirth: state.dateOfBirth!,
        nicFile: state.nicFile!,
        passportFile: state.passportFile,
        driverLicenseFile: state.driverLicenseFile,
      );
      
      // Update local profile directly to show pending state immediately
      ref.invalidate(currentUserProvider);
      
      notifier.setSuccess();
      notifier.nextStep(); // Move to success/pending screen
    } catch (e) {
      notifier.setError(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostVerificationFlowProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upload Documents'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(hostVerificationFlowProvider.notifier).previousStep();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Verify your identity',
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Clear, readable photos help speed up approval.',
                style: AppTypography.bodyMediumSecondary,
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              Expanded(
                child: ListView(
                  children: [
                    _buildDocumentPicker(
                      title: 'National Identity Card (NIC)',
                      subtitle: 'Required',
                      file: state.nicFile,
                      isRequired: true,
                      onTap: () => _pickImage('nic'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDocumentPicker(
                      title: 'Passport',
                      subtitle: 'Optional',
                      file: state.passportFile,
                      isRequired: false,
                      onTap: () => _pickImage('passport'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDocumentPicker(
                      title: 'Driver\'s License',
                      subtitle: 'Optional',
                      file: state.driverLicenseFile,
                      isRequired: false,
                      onTap: () => _pickImage('license'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              ZeyloButton(
                label: 'Submit for Review',
                isLoading: state.isSubmitting,
                onPressed: state.nicFile != null && !state.isSubmitting
                    ? _submitVerification
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentPicker({
    required String title,
    required String subtitle,
    required XFile? file,
    required bool isRequired,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AppTypography.labelLarge),
            if (isRequired)
              const Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: file != null ? AppColors.primary : AppColors.border,
                width: file != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: file != null ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
              image: file != null
                  ? DecorationImage(
                      image: kIsWeb 
                          ? NetworkImage(file.path) as ImageProvider
                          : FileImage(File(file.path)),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4),
                        BlendMode.darken,
                      ),
                    )
                  : null,
            ),
            child: Center(
              child: file != null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 32),
                        SizedBox(height: AppSpacing.xs),
                        Text('Image Attached', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: AppColors.textSecondary, size: 32),
                        SizedBox(height: AppSpacing.xs),
                        Text('Tap to upload', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
