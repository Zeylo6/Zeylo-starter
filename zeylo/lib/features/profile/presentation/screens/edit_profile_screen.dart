import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  bool _isLoading = false;
  Uint8List? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider(widget.userId));

    return profileAsync.when(
      data: (profile) {
        // Initialize controllers with profile data
        if (_nameController.text.isEmpty) {
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
          style: AppTypography.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.divider,
                    backgroundImage: _selectedImage != null
                        ? MemoryImage(_selectedImage!)
                        : (profile.photoUrl != null
                            ? CachedNetworkImageProvider(profile.photoUrl!)
                            : null) as ImageProvider?,
                    child: _selectedImage == null && profile.photoUrl == null
                        ? const Icon(Icons.person,
                            size: 60, color: AppColors.textHint)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Name field
            ZeyloTextField(
              label: 'Full Name',
              hint: 'Your full name',
              controller: _nameController,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: AppSpacing.md),

            // Email field
            ZeyloTextField(
              label: 'Email',
              hint: 'your.email@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.md),

            // Phone field
            ZeyloTextField(
              label: 'Phone Number',
              hint: '+1 (555) 000-0000',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.md),

            // Bio field
            ZeyloTextField(
              label: 'Bio',
              hint: 'Tell us about yourself',
              controller: _bioController,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Save button
            ZeyloButton(
              onPressed: _isLoading ? null : _handleSave,
              label: 'Save Changes',
              isLoading: _isLoading,
              variant: ButtonVariant.filled,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        setState(() {
          _selectedImage = imageBytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileAsync = ref.read(profileProvider(widget.userId));
      final profile = profileAsync.valueOrNull;
      if (profile == null) return;

      final repository = ref.read(profileRepositoryProvider);
      String? newPhotoUrl = profile.photoUrl;

      // 1. Upload new image if selected
      if (_selectedImage != null) {
        final uploadResult = await repository.uploadProfileImage(
          widget.userId,
          _selectedImage!,
        );

        uploadResult.fold(
          (failure) => throw Exception('Image upload failed: ${failure.message}'),
          (url) => newPhotoUrl = url,
        );
      }

      // 2. Update profile
      final updatedProfile = profile.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        bio: _bioController.text,
        photoUrl: newPhotoUrl,
      );

      final result =
          await repository.updateProfile(widget.userId, updatedProfile);

      if (!mounted) return;

      await result.fold(
        (failure) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          );
        },
        (_) async {
          // 3. Sync profile to experiences if it's a host
          // We don't have a clear "isHost" check here easily, but we can call it anyway
          // or check if they have any experiences. For simplicity, we call it.
          await repository.syncHostProfileToExperiences(
            widget.userId,
            _nameController.text,
            newPhotoUrl,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
            Navigator.pop(context);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
