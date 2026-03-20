import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/moment_entity.dart';
import '../providers/community_provider.dart';

class CreateMomentScreen extends ConsumerStatefulWidget {
  const CreateMomentScreen({super.key});

  @override
  ConsumerState<CreateMomentScreen> createState() => _CreateMomentScreenState();
}

class _CreateMomentScreenState extends ConsumerState<CreateMomentScreen> {
  final _captionController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
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

  Future<void> _uploadAndPost() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final imageUrl = await CloudinaryService.uploadImage(_imageFile!);

      if (imageUrl == null) {
        throw Exception('Failed to upload image to Cloudinary');
      }

      final user = ref.read(currentUserProvider).value;
      if (user == null) throw Exception('User not authenticated');

      final moment = Moment(
        id: '', // Firestore will generate
        userId: user.uid,
        userName: user.displayName,
        userAvatar: user.photoUrl ?? '',
        imageUrl: imageUrl,
        caption: _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      await ref.read(addMomentProvider(moment).future);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Moment posted! It will disappear in 24 hours.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting moment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_imageFile != null && !_isUploading)
            TextButton(
              onPressed: _uploadAndPost,
              child: Text(
                'Share',
                style:
                    AppTypography.labelLarge.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: _imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      Icon(Icons.camera_alt_outlined,
                          size: 64, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Share a Moment',
                        style: AppTypography.headlineMedium
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildOptionButton(
                            icon: Icons.photo_library,
                            label: 'Gallery',
                            onTap: () => _pickImage(ImageSource.gallery),
                          ),
                          const SizedBox(width: AppSpacing.xxl),
                          _buildOptionButton(
                            icon: Icons.camera_alt,
                            label: 'Camera',
                            onTap: () => _pickImage(ImageSource.camera),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 9 / 16,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: TextField(
                          controller: _captionController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black54,
                            hintText: 'Add a caption...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.edit, color: Colors.white70),
                          ),
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),
                    ],
                  ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label,
              style: AppTypography.bodySmall.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
