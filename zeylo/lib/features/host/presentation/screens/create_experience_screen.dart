import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../features/chain/presentation/providers/chain_provider.dart'; // Contains aiServiceProvider

class CreateExperienceScreen extends ConsumerStatefulWidget {
  const CreateExperienceScreen({super.key});

  @override
  ConsumerState<CreateExperienceScreen> createState() =>
      _CreateExperienceScreenState();
}

class _CreateExperienceScreenState extends ConsumerState<CreateExperienceScreen> {
  final _titleController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxGuestsController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  
  bool _isLoading = false;
  bool _isAIEnhancing = false;

  @override
  void dispose() {
    _titleController.dispose();
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
      final prompt = "Make this experience description sound highly professional, extremely exciting, and incredibly immersive for a premium discovery app. Return ONLY the enhanced description without conversational padding: $currentDesc";
      
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

  Future<void> _submitExperience() async {
    final title = _titleController.text.trim();
    final shortDesc = _shortDescController.text.trim();
    final desc = _descController.text.trim();
    final priceStr = _priceController.text.trim();
    final durationStr = _durationController.text.trim();
    final maxGuestsStr = _maxGuestsController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();

    if (title.isEmpty || shortDesc.isEmpty || desc.isEmpty || priceStr.isEmpty ||
        durationStr.isEmpty || maxGuestsStr.isEmpty || address.isEmpty || city.isEmpty) {
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

      // Generate a new document ID
      final docRef = FirebaseFirestore.instance.collection('experiences').doc();

      await docRef.set({
        'id': docRef.id,
        'title': title,
        'shortDescription': shortDesc,
        'description': desc,
        'hostId': user.uid,
        'hostName': user.displayName ?? 'Zeylo Host',
        'hostPhotoUrl': user.photoURL ?? '',
        'category': 'Activities', // Default for now
        'subcategory': 'General',
        'images': [], 
        'coverImage': 'https://firebasestorage.googleapis.com/v0/b/zeylo-app.appspot.com/o/placeholders%2Fplaceholder_experience.jpg?alt=media', // placeholder
        'price': price,
        'currency': 'USD',
        'duration': duration,
        'maxGuests': maxGuests,
        'location': {
          'address': address,
          'city': city,
          'country': 'Sri Lanka',
          'geoPoint': {'latitude': 6.9271, 'longitude': 79.8612}, // Default Colombo
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
        Navigator.pop(context); // Return to Dashboard
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create Listing', style: AppTypography.titleMedium),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Basic Info', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.md),
            
            _buildTextField(_titleController, 'Experience Title', 'e.g., Sunset Surfing'),
            const SizedBox(height: AppSpacing.sm),
            _buildTextField(_shortDescController, 'Short Description', 'A catchy one liner...'),
            const SizedBox(height: AppSpacing.sm),
            
            // Description with AI Button
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Full Description',
                hintText: 'What will guests do?',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                suffixIcon: IconButton(
                  icon: _isAIEnhancing 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome, color: AppColors.secondary),
                  onPressed: _isAIEnhancing ? null : _enhanceDescriptionWithAI,
                  tooltip: 'Enhance with AI',
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            Text('Details', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.md),
            
            Row(
              children: [
                Expanded(child: _buildTextField(_priceController, 'Price (USD)', 'e.g., 50', isNumber: true)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _buildTextField(_durationController, 'Duration (mins)', 'e.g., 120', isNumber: true)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildTextField(_maxGuestsController, 'Max Guests allowed', 'e.g., 4', isNumber: true),

            const SizedBox(height: AppSpacing.lg),
            Text('Location', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.md),
            
            _buildTextField(_addressController, 'Street Address', '123 Beach Rd'),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Publish Experience', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );
  }
}
