import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../features/chain/presentation/providers/chain_provider.dart'; // Contains aiServiceProvider
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import 'package:go_router/go_router.dart';

class CreateExperienceScreen extends ConsumerStatefulWidget {
  const CreateExperienceScreen({super.key});

  @override
  ConsumerState<CreateExperienceScreen> createState() =>
      _CreateExperienceScreenState();
}

class _CreateExperienceScreenState extends ConsumerState<CreateExperienceScreen> {
  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxGuestsController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isLoading = false;
  bool _isAIEnhancing = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _maxGuestsController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _enhanceDescriptionWithAI() async {
    final currentDesc = _descController.text.trim();
    if (currentDesc.length < 20) {
      _showSnackbar("Write at least a basic outline (20+ chars) before enhancing.");
      return;
    }

    setState(() => _isAIEnhancing = true);
    try {
      final aiService = ref.read(aiServiceProvider);
      final prompt =
          "Make this experience description sound highly professional, extremely exciting, and incredibly immersive for a premium discovery app. Return ONLY the enhanced description without conversational padding: $currentDesc";

      final enhancedDesc = await aiService.enhancePrompt(prompt);

      if (mounted) {
        setState(() {
          _descController.text = enhancedDesc;
        });
        _showSnackbar("Description enhanced!", isError: false);
      }
    } catch (e) {
      _showSnackbar("AI Enhancement failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isAIEnhancing = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackbar("Failed to pick image: $e");
    }
  }

  /// Uploads to Cloudinary using Unsigned Preset
  Future<String?> _uploadToCloudinary() async {
    if (_selectedImage == null) return null;

    const cloudName = 'deukwmcoi';
    const uploadPreset = 'Zeylo_images';

    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return jsonMap['secure_url'];
      } else {
        debugPrint('Cloudinary Error: ${jsonMap['error']['message']}');
        return null;
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }

  void _generateRandomImage() {
    final title = _titleController.text.trim();
    final keyword = title.isNotEmpty ? Uri.encodeComponent(title.split(' ').first) : 'nature';
    setState(() {
      _imageUrlController.text = 'https://source.unsplash.com/featured/1200x800/?$keyword';
    });
  }

  Future<void> _submitExperience() async {
    final title = _titleController.text.trim();
    final manualImageUrl = _imageUrlController.text.trim();
    final shortDesc = _shortDescController.text.trim();
    final desc = _descController.text.trim();
    final priceStr = _priceController.text.trim();
    final durationStr = _durationController.text.trim();
    final maxGuestsStr = _maxGuestsController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();

    if (title.isEmpty ||
        shortDesc.isEmpty ||
        desc.isEmpty ||
        priceStr.isEmpty ||
        durationStr.isEmpty ||
        maxGuestsStr.isEmpty ||
        address.isEmpty ||
        city.isEmpty) {
      _showSnackbar("All fields are required.");
      return;
    }

    final price = double.tryParse(priceStr);
    final duration = int.tryParse(durationStr);
    final maxGuests = int.tryParse(maxGuestsStr);

    if (price == null || duration == null || maxGuests == null) {
      _showSnackbar("Price, Duration, and Guests must be valid numbers.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final docRef = FirebaseFirestore.instance.collection('experiences').doc();
      final experienceId = docRef.id;

      // Upload to Cloudinary first if an image is selected
      String? finalImageUrl;
      if (_selectedImage != null) {
        finalImageUrl = await _uploadToCloudinary();
        if (finalImageUrl == null) {
          _showSnackbar("Image upload failed. Please try again.");
          setState(() => _isLoading = false);
          return;
        }
      }

      // Fallback: 1. Cloudinary URL, 2. Manual URL, 3. Placeholder
      finalImageUrl ??= manualImageUrl.isNotEmpty
          ? manualImageUrl
          : 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200';

      await docRef.set({
        'id': experienceId,
        'title': title,
        'shortDescription': shortDesc,
        'description': desc,
        'hostId': user.uid,
        'hostName': user.displayName ?? 'Zeylo Host',
        'hostPhotoUrl': user.photoURL ?? '',
        'category': 'Activities',
        'subcategory': 'General',
        'images': [finalImageUrl],
        'coverImage': finalImageUrl,
        'price': price,
        'currency': 'USD',
        'duration': duration,
        'maxGuests': maxGuests,
        'location': {
          'address': address,
          'city': city,
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.9271, 'longitude': 79.8612},
        },
        'includes': [],
        'requirements': [],
        'languages': ['English'],
        'averageRating': 0.0,
        'reviewCount': 0,
        'isActive': true,
        'isMysteryAvailable': false,
        'tags': [],
        'availability': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSnackbar("Experience created successfully!", isError: false);
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackbar("Failed to create experience: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create Listing', style: AppTypography.titleMedium),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null || user.hostVerificationStatus != HostVerificationStatus.verified) {
            return _buildVerificationRequiredView(context, user?.hostVerificationStatus);
          }
          return _buildForm(context);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading user data')),
      ),
    );
  }

  Widget _buildVerificationRequiredView(BuildContext context, HostVerificationStatus? status) {
    String title = 'Verification Required';
    String message = 'You must verify your identity before you can create an experience listing.';
    String actionParams = '/host-verification';
    String actionLabel = 'Start Verification';

    if (status == HostVerificationStatus.pending) {
      title = 'Verification Pending';
      message = 'Your identity documents are currently under review. We will notify you once approved.';
      actionParams = '/host-verification-pending';
      actionLabel = 'View Status';
    } else if (status == HostVerificationStatus.rejected) {
      title = 'Verification Rejected';
      message = 'Your previous verification attempt was rejected. Please review our policies and try again.';
      actionLabel = 'Try Again';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.gpp_bad_outlined, size: 80, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTypography.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.push(actionParams),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                child: Text(actionLabel, style: AppTypography.labelLarge.copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Go Back', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cover Image', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.md),

            // Image Picker Box (uploads to Cloudinary)
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate,
                              size: 40, color: AppColors.primary),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Upload Cover Photo',
                              style: AppTypography.titleMedium),
                          Text('Tap to pick from gallery',
                              style: AppTypography.bodySmallSecondary),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            const Center(
              child: Text('OR',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: AppSpacing.md),

            // Manual URL Fallback
            TextField(
              controller: _imageUrlController,
              onChanged: (val) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Paste Image Link Instead',
                hintText: 'https://...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.auto_awesome,
                      color: AppColors.secondary),
                  onPressed: _generateRandomImage,
                  tooltip: 'Get random image based on title',
                ),
              ),
            ),

            if (_imageUrlController.text.isNotEmpty && _selectedImage == null) ...[
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.network(
                  _imageUrlController.text,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 200,
                    color: AppColors.surface,
                    child: const Center(child: Text('Invalid Image URL')),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
            Text('Basic Info', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.md),

            _buildTextField(_titleController, 'Experience Title',
                'e.g., Sunset Surfing'),
            const SizedBox(height: AppSpacing.sm),
            _buildTextField(_shortDescController, 'Short Description',
                'A catchy one liner...'),
            const SizedBox(height: AppSpacing.sm),

            // Description with AI Button
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Full Description',
                hintText: 'What will guests do?',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm)),
                suffixIcon: IconButton(
                  icon: _isAIEnhancing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome,
                          color: AppColors.secondary),
                  onPressed:
                      _isAIEnhancing ? null : _enhanceDescriptionWithAI,
                  tooltip: 'Enhance with AI',
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Text('Details', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                    child: _buildTextField(_priceController, 'Price (USD)',
                        'e.g., 50',
                        isNumber: true)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                    child: _buildTextField(_durationController,
                        'Duration (mins)', 'e.g., 120',
                        isNumber: true)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildTextField(_maxGuestsController, 'Max Guests allowed',
                'e.g., 4',
                isNumber: true),

            const SizedBox(height: AppSpacing.lg),
            Text('Location', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.md),

            _buildTextField(
                _addressController, 'Street Address', '123 Beach Rd'),
            const SizedBox(height: AppSpacing.sm),
            _buildTextField(_cityController, 'City', 'Weligama'),

            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitExperience,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Publish Experience',
                        style: AppTypography.labelLarge
                            .copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );
  }
}
