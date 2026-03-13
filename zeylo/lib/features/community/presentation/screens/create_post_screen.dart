import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/post_entity.dart';
import '../providers/community_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _captionController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isPublishing = false;

  @override
  void dispose() {
    _captionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _images.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<List<String>> _uploadToCloudinary() async {
    const cloudName = 'deukwmcoi';
    const uploadPreset = 'Zeylo_images';
    final List<String> imageUrls = [];

    for (final file in _images) {
      try {
        final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
        final request = http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

        final response = await request.send();
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);

        if (response.statusCode == 200) {
          imageUrls.add(jsonMap['secure_url'] as String);
        } else {
          debugPrint('Cloudinary Error: ${jsonMap['error']?['message'] ?? 'Unknown error'}');
        }
      } catch (e) {
        debugPrint("Upload error: $e");
      }
    }

    return imageUrls;
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag.startsWith('#') ? tag : '#$tag');
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _publishPost() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty && _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something or add an image to post')),
      );
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post')),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      // 1. Upload images if any
      final List<String> imageUrls = await _uploadToCloudinary();

      if (_images.isNotEmpty && imageUrls.isEmpty) {
        throw Exception("Failed to upload images");
      }

      final newPost = Post(
        id: '', // Firestore will generate this
        userId: user.uid,
        userName: user.displayName,
        userAvatar: user.photoUrl ?? '',
        images: imageUrls,
        caption: caption,
        likesCount: 0,
        commentsCount: 0,
        createdAt: DateTime.now(),
        tags: _tags.map((t) => t.replaceAll('#', '')).toList(),
      );

      final repository = ref.read(communityRepositoryProvider);
      final result = await repository.createPost(newPost);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to publish post: ${failure.message}')),
            );
          }
        },
        (postId) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post published successfully!')),
            );
            context.pop();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: ElevatedButton(
              onPressed: _isPublishing ? null : _publishPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textInverse,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                elevation: 0,
              ),
              child: _isPublishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.textInverse),
                      ),
                    )
                  : const Text('Publish'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info row
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    backgroundColor: AppColors.surface,
                    child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                        ? const Icon(Icons.person, color: AppColors.textSecondary)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    user?.displayName ?? 'Loading...',
                    style: AppTypography.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Text Field
              TextField(
                controller: _captionController,
                maxLines: 6,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                ),
                style: AppTypography.bodyLarge,
              ),
              
              const SizedBox(height: AppSpacing.md),

              // Image Preview
              if (_images.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Image.file(
                              _images[index],
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.md),

              // Tags input
              Text('Tags', style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        hintText: 'Add a tag (e.g. #hiking)',
                        hintStyle: AppTypography.bodyMediumSecondary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: _addTag,
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  ),
                ],
              ),
              
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _tags.map((tag) => Chip(
                    label: Text(tag, style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    deleteIconColor: AppColors.primary,
                    onDeleted: () => _removeTag(tag),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      side: BorderSide.none,
                    ),
                  )).toList(),
                ),
              ],
              
              const SizedBox(height: AppSpacing.xl),
              
              // Interaction Buttons
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.image_outlined, color: AppColors.primary),
                    label: Text('Add Photos', style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link experience coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
