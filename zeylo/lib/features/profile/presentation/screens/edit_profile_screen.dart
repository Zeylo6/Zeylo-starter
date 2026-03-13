import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../providers/profile_provider.dart';

/// Edit profile screen
class EditProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const EditProfileScreen({
    required this.userId,
    super.key,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider(widget.userId));

    return profileAsync.when(
      data: (profile) {
        // Initialize controllers with profile data
        if (_nameController.text.isEmpty && !_isLoading) {
          _nameController.text = profile.name;
          _emailController.text = profile.email ?? '';
          _phoneController.text = profile.phone ?? '';
          _bioController.text = profile.bio ?? '';
        }

        return _buildContent(context, ref, profile);
      },
      loading: () => Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserProfileEntity profile,
  ) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile image section (Hero with premium overlay)
              Center(
                child: Stack(
                  children: [
                    Hero(
                      tag: 'profile_avatar_${widget.userId}',
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainerLow, // Fallback color
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : (profile.photoUrl != null &&
                                      profile.photoUrl!.isNotEmpty
                                  ? DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          profile.photoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        ),
                        child: _imageFile == null &&
                                (profile.photoUrl == null ||
                                    profile.photoUrl!.isEmpty)
                            ? Icon(
                                Icons.person_rounded,
                                size: 64,
                                color: AppColors.primary.withOpacity(0.5),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Inputs Grouped in a Section
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ZeyloTextField(
                      label: 'Full Name',
                      hint: 'Your full name',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ZeyloTextField(
                      label: 'Email Address',
                      hint: 'your.email@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ZeyloTextField(
                      label: 'Phone Number',
                      hint: '+1 (555) 000-0000',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ZeyloTextField(
                      label: 'Short Bio',
                      hint: 'Tell us a bit about your experiences...',
                      controller: _bioController,
                      maxLines: 4,
                      prefixIcon: const Icon(Icons.description_outlined, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Action Chips (Modern Save/Cancel)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Cancel', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ZeyloButton(
                      onPressed: _isLoading ? null : () => _handleSave(profile),
                      label: 'Save Changes',
                      isLoading: _isLoading,
                      variant: ButtonVariant.filled,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(UserProfileEntity profile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(profileRepositoryProvider);
      String? updatedPhotoUrl = profile.photoUrl;

      // 1. Upload new image if selected
      if (_imageFile != null) {
        final imageBytes = await _imageFile!.readAsBytes();
        final uploadResult = await repository.uploadProfileImage(
          widget.userId,
          imageBytes,
        );

        uploadResult.fold(
          (failure) => throw Exception('Failed to upload image: ${failure.message}'),
          (url) => updatedPhotoUrl = url,
        );
      }

      // 2. Update profile
      final updatedProfile = profile.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        bio: _bioController.text,
        photoUrl: updatedPhotoUrl,
        updatedAt: DateTime.now(),
      );

      final result = await repository.updateProfile(widget.userId, updatedProfile);

      await result.fold(
        (failure) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          );
        },
        (_) async {
          // 3. Sync to experiences if name or photo changed
          if (profile.name != updatedProfile.name ||
              profile.photoUrl != updatedProfile.photoUrl) {
            await repository.syncHostProfileToExperiences(
              widget.userId,
              updatedProfile.name,
              updatedProfile.photoUrl,
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          
          // Refresh profile data
          ref.read(profileProvider(widget.userId).notifier).loadProfile();
          
          Navigator.pop(context);
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
