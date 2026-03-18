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
import '../../../../features/chain/presentation/providers/chain_provider.dart'; 
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/location_picker.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Create Experience Screen
/// Responsive layout built for web interface
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
  LatLng? _selectedLatLng;
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
      final enhancedDesc = await aiService.enhanceText(currentDesc, 'host_experience');

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

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final isHostVerified = userDoc.data()?['hostVerificationStatus'] == 'verified';

      String? finalImageUrl;
      if (_selectedImage != null) {
        finalImageUrl = await _uploadToCloudinary();
        if (finalImageUrl == null) {
          _showSnackbar("Image upload failed. Please try again.");
          setState(() => _isLoading = false);
          return;
        }
      }

      finalImageUrl ??= manualImageUrl.isNotEmpty
          ? manualImageUrl
          : 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200';

      await docRef.set({
        'id': experienceId,
        'title': title,
        'shortDescription': shortDesc,
        'description': desc,
        'hostId': user.uid,
        'hostName': userDoc.data()?['displayName'] ?? user.displayName ?? 'Zeylo Host',
        'hostPhotoUrl': userDoc.data()?['photoUrl'] ?? user.photoURL ?? '',
        'isHostVerified': isHostVerified,
        'category': 'Activities',
        'subcategory': 'General',
        'images': [finalImageUrl],
        'coverImage': finalImageUrl,
        'price': price,
        'currency': 'LKR',
        'duration': duration,
        'maxGuests': maxGuests,
        'location': {
          'address': address,
          'city': city,
          'country': 'Sri Lanka',
          'geoPoint': _selectedLatLng != null 
            ? {'latitude': _selectedLatLng!.latitude, 'longitude': _selectedLatLng!.longitude}
            : {'latitude': 6.9271, 'longitude': 79.8612},
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
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create Listing', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: isDesktop ? null : const BackButton(color: AppColors.textPrimary),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null || user.hostVerificationStatus != HostVerificationStatus.verified) {
            return _buildVerificationRequiredView(context, user?.hostVerificationStatus);
          }
          return _buildFormLayout(context, isDesktop);
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
              width: 300,
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

  Widget _buildFormLayout(BuildContext context, bool isDesktop) {
    // Media & Identity Block
    final identityBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Experience Identity', Icons.auto_awesome_mosaic_rounded),
        const SizedBox(height: AppSpacing.md),
        _buildMediaPicker(),
        const SizedBox(height: AppSpacing.lg),
        _buildFormSection(
          children: [
            _buildModernTextField(_titleController, 'Experience Title', 'e.g., Sunset Surfing', Icons.title_rounded),
             const SizedBox(height: AppSpacing.lg),
            _buildModernTextField(_shortDescController, 'Catchy One-Liner', 'A brief, exciting hook...', Icons.short_text_rounded),
          ],
        ),
      ]
    );

    // Narrative Block
    final narrativeBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('The Story', Icons.description_rounded),
        const SizedBox(height: AppSpacing.md),
        _buildNarrativeSection(),
      ],
    );

    // Logistics Block
    final logisticsBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         _buildSectionHeader('Logistics & Pricing', Icons.monetization_on_rounded),
         const SizedBox(height: AppSpacing.md),
         _buildFormSection(
          children: [
            Row(
              children: [
                Expanded(child: _buildModernTextField(_priceController, 'Price (LKR)', '5000', Icons.payments_rounded, isNumber: true)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildModernTextField(_durationController, 'Mins', '120', Icons.timer_outlined, isNumber: true)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildModernTextField(_maxGuestsController, 'Group Size Limit', 'e.g., 4', Icons.groups_rounded, isNumber: true),
          ],
        ),
      ]
    );

    // Location Block
    final locationBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         _buildSectionHeader('Location Mapping', Icons.location_on_rounded),
         const SizedBox(height: AppSpacing.md),
         _buildLocationSection(),
      ]
    );

    // Form Controls
    final actionControls = Row(
      children: [
         Expanded(
           child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Save Draft', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
           ),
         ),
         const SizedBox(width: AppSpacing.md),
         Expanded(
           child: ZeyloButton(
              onPressed: _isLoading ? null : _submitExperience,
              label: 'Publish Experience',
              isLoading: _isLoading,
              variant: ButtonVariant.filled,
           ),
         ),
      ]
    );

    if (isDesktop) {
       return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl, vertical: AppSpacing.xl),
            child: ConstrainedBox(
               constraints: const BoxConstraints(maxWidth: 1200),
               child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     // Left Panel
                     Expanded(
                        flex: 1,
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              identityBlock,
                              const SizedBox(height: AppSpacing.xl),
                              narrativeBlock,
                           ],
                        ),
                     ),
                     const SizedBox(width: AppSpacing.xxxl),
                     // Right Panel
                     Expanded(
                        flex: 1,
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              logisticsBlock,
                              const SizedBox(height: AppSpacing.xl),
                              locationBlock,
                              const SizedBox(height: AppSpacing.xxxl),
                              actionControls,
                           ],
                        )
                     )
                  ],
               ),
            ),
          ),
       );
    } // Mobile layout
    return SingleChildScrollView(
       padding: const EdgeInsets.all(AppSpacing.lg),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            identityBlock,
            const SizedBox(height: AppSpacing.xl),
            narrativeBlock,
            const SizedBox(height: AppSpacing.xl),
            logisticsBlock,
            const SizedBox(height: AppSpacing.xl),
            locationBlock,
            const SizedBox(height: AppSpacing.xxxl),
            actionControls,
            const SizedBox(height: AppSpacing.xxl),
         ],
       )
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection({required List<Widget> children}) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildMediaPicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_photo_alternate_rounded,
                            size: 32, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Upload Cover Illustration',
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Tap to select from local storage',
                          style: AppTypography.bodySmallSecondary),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildModernTextField(_imageUrlController, 'Or Paste Image URL', 'https://...', Icons.link_rounded, 
          suffix: IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
            onPressed: _generateRandomImage,
            tooltip: 'Auto-generate',
          ),
        ),
      ],
    );
  }

  Widget _buildNarrativeSection() {
    return _buildFormSection(
      children: [
        TextField(
          controller: _descController,
          maxLines: 6,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            labelText: 'Full Description',
            hintText: 'What makes this experience unique?',
            alignLabelWithHint: true,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: Icon(Icons.history_edu_rounded, size: 20),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 100, right: 8),
              child: IconButton(
                icon: _isAIEnhancing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary),
                onPressed: _isAIEnhancing ? null : _enhanceDescriptionWithAI,
                tooltip: 'Enhance with AI ✨',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildFormSection(
      children: [
        _buildModernTextField(_addressController, 'Street Address', '123 Beach Rd', Icons.location_city_rounded),
        const SizedBox(height: AppSpacing.lg),
        _buildModernTextField(_cityController, 'City', 'Weligama', Icons.map_rounded),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push<LocationResult>(
                context,
                MaterialPageRoute(builder: (context) => const ZeyloLocationPicker()),
              );
              if (result != null) {
                setState(() {
                  _addressController.text = result.address;
                  _cityController.text = result.city;
                  _selectedLatLng = result.latLng;
                });
              }
            },
            icon: const Icon(Icons.explore_rounded, size: 20),
            label: Text(_selectedLatLng == null ? 'Set Location on Map' : 'Update Map Coordinates'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerLow,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField(TextEditingController controller, String label, String hint, IconData icon, {bool isNumber = false, Widget? suffix}) {
    return ZeyloTextField(
      controller: controller,
      label: label,
      hint: hint,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary.withOpacity(0.7)),
      child: suffix,
    );
  }
}
