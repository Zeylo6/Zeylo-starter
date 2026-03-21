import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/chain_entity.dart';
import '../providers/chain_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/interest_chip_list.dart';
import '../widgets/time_selector.dart';

/// Create chain (mini trip) screen
class CreateChainScreen extends ConsumerStatefulWidget {
  final String userId;

  const CreateChainScreen({
    required this.userId,
    super.key,
  });

  @override
  ConsumerState<CreateChainScreen> createState() => _CreateChainScreenState();
}

class _CreateChainScreenState extends ConsumerState<CreateChainScreen> {
  late TextEditingController _destinationController;
  late TextEditingController _dateController;
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController();
    _dateController = TextEditingController();
    _promptController = TextEditingController();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _dateController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  List<String> _getWordSuggestions(String text) {
    if (text.isEmpty) return [];
    final words = text.toLowerCase().split(' ');
    final lastWord = words.last;
    if (lastWord.isEmpty) return [];
    
    final Map<String, List<String>> dict = {
      'relaxing': ['morning', 'day', 'evening', 'spa', 'beach', 'getaway'],
      'energetic': ['afternoon', 'morning', 'hike', 'adventure', 'day'],
      'cultural': ['evening', 'tour', 'experience', 'village', 'heritage'],
      'romantic': ['dinner', 'evening', 'getaway', 'sunset', 'date'],
      'scenic': ['views', 'drive', 'hike', 'sunset', 'morning'],
      'chill': ['vibes', 'evening', 'afternoon', 'cafe', 'lounge'],
      'exciting': ['adventure', 'nightlife', 'safari', 'trip'],
      'thrilling': ['experience', 'activity', 'ride', 'sport'],
      'peaceful': ['morning', 'retreat', 'walk', 'sunset'],
      'local': ['food', 'tour', 'culture', 'market', 'experience'],
      'adventurous': ['day', 'hike', 'trip', 'sport'],
      'food': ['tour', 'tasting', 'market', 'class', 'crawl'],
    };

    if (dict.containsKey(lastWord)) {
      return dict[lastWord]!;
    }

    for (var key in dict.keys) {
      if (key.startsWith(lastWord) && key != lastWord) {
        return [key];
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(chainFormProvider(widget.userId), (previous, next) {
      if (previous?.prompt != next.prompt &&
          _promptController.text != next.prompt) {
        _promptController.text = next.prompt;
      }
    });

    final formState = ref.watch(chainFormProvider(widget.userId));
    final formNotifier = ref.read(chainFormProvider(widget.userId).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.link,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Center(
                child: Text(
                  'Create Your Mini Trip Today!',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Center(
                child: Text(
                  'Connect multiple experiences for the perfect day using our AI.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              ZeyloTextField(
                label: 'Describe your perfect day',
                hint:
                    'E.g., I want a relaxing morning, energetic afternoon, and cultural evening.',
                controller: _promptController,
                maxLines: 3,
                prefixWidget: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 20,
                ),
                suffixWidget: IconButton(
                  icon: formState.isEnhancing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(
                          Icons.auto_fix_high,
                          color: AppColors.primary,
                        ),
                  tooltip: 'Enhance Prompt',
                  onPressed: formState.isEnhancing
                      ? null
                      : () => formNotifier.enhancePrompt(),
                ),
                onChanged: (value) {
                  formNotifier.setPrompt(value);
                  setState(() {}); // refresh suggestions
                },
              ),
              if (_getWordSuggestions(_promptController.text).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    children: _getWordSuggestions(_promptController.text)
                        .map((word) => ActionChip(
                              label: Text(word, style: AppTypography.labelSmall),
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              onPressed: () {
                                final currentText = _promptController.text;
                                final words = currentText.split(' ');
                                words.removeLast();
                                words.add(word);
                                final newText = '${words.join(' ')} ';
                                _promptController.text = newText;
                                _promptController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: newText.length));
                                formNotifier.setPrompt(newText);
                                setState(() {});
                              },
                            ))
                        .toList(),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),

              ZeyloTextField(
                label: 'Destination City',
                hint: 'Where do you want to explore?',
                controller: _destinationController,
                prefixWidget: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onChanged: (value) => formNotifier.setDestinationCity(value),
              ),
              const SizedBox(height: AppSpacing.lg),

              ZeyloTextField(
                label: 'Date',
                hint: 'mm/dd/yyyy',
                controller: _dateController,
                prefixWidget: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onChanged: (value) => formNotifier.setDate(value),
                readOnly: true,
                onTap: () => _selectDate(context, formNotifier),
              ),
              const SizedBox(height: AppSpacing.lg),

              TimeSelector(
                selectedDuration: formState.totalTime,
                onDurationSelected: (duration) =>
                    formNotifier.setTotalTime(duration),
              ),
              const SizedBox(height: AppSpacing.lg),

              InterestChipList(
                selectedInterests: formState.selectedInterests,
                onInterestToggled: (interest) =>
                    formNotifier.toggleInterest(interest),
              ),
              const SizedBox(height: AppSpacing.xl),

              if (formState.experiences.isEmpty) ...[
                ZeyloButton(
                  label: formState.isGenerating
                      ? 'Generating...'
                      : 'Generate AI Chain',
                  isLoading: formState.isGenerating,
                  isDisabled: formState.isGenerating ||
                      formState.prompt.isEmpty ||
                      formState.destinationCity.isEmpty,
                  onPressed: formState.isGenerating
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          formNotifier
                              .setName('${_destinationController.text} Trip');
                          formNotifier.generateExperiences();
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                ZeyloButton(
                  label: 'Select Experiences Manually',
                  variant: ButtonVariant.outlined,
                  isDisabled: formState.destinationCity.isEmpty,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    formNotifier.setName('${_destinationController.text} Trip');
                    _showManualSelectionSheet(context, formNotifier, formState);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
              ] else ...[
                _buildDynamicChainSection(formState.experiences),
                const SizedBox(height: AppSpacing.md),
                
                // NEW: Give the user an option to keep adding or clear the chain!
                Row(
                  children: [
                    Expanded(
                      child: ZeyloButton(
                        label: '+ Add Experience',
                        variant: ButtonVariant.outlined,
                        onPressed: () => _showManualSelectionSheet(context, formNotifier, formState),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ZeyloButton(
                        label: 'Clear All',
                        backgroundColor: AppColors.error,
                        onPressed: () {
                          // Let's pop all experiences by clearing the state array
                          // Actually formNotifier doesn't have a clear methods. We can remove one by one.
                          for (int i = formState.experiences.length - 1; i >= 0; i--) {
                            formNotifier.removeExperience(i);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              if (formState.error != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    formState.error!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              if (formState.error != null)
                const SizedBox(height: AppSpacing.lg),

              ZeyloButton(
                label: formState.isLoading ? 'Creating...' : 'Create',
                isLoading: formState.isLoading,
                isDisabled: formState.isLoading,
                onPressed: formState.isLoading
                    ? null
                    : () async {
                        await formNotifier.submitForm();

                        final latestState =
                            ref.read(chainFormProvider(widget.userId));

                        if (latestState.error == null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chain created successfully!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicChainSection(List<ChainExperience> experiences) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generated Experiences',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...experiences.asMap().entries.map((entry) {
            final index = entry.key;
            final exp = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _buildSuggestedExperience(
                position: index + 1,
                experience: exp,
                isLast: index == experiences.length - 1,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSuggestedExperience({
    required int position,
    required ChainExperience experience,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$position',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 90,
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: AppColors.primary.withOpacity(0.35),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: experience.imageUrl.isNotEmpty
                          ? Image.network(
                              experience.imageUrl,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildImageFallback(),
                            )
                          : _buildImageFallback(),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (experience.category.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                experience.category,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (experience.category.isNotEmpty)
                            const SizedBox(height: 8),
                          Text(
                            experience.title,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${experience.startTime} - ${experience.endTime}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${experience.duration.toStringAsFixed(1)}h • Rs. ${experience.price.toStringAsFixed(0)}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // NEW: Allow user to actually remove an individual experience!
                Positioned(
                  top: -8,
                  right: -8,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: AppColors.error),
                    onPressed: () {
                      final formNotifier = ref.read(chainFormProvider(widget.userId).notifier);
                      formNotifier.removeExperience(position - 1);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageFallback() {
    return Container(
      width: 88,
      height: 88,
      color: AppColors.primary.withOpacity(0.08),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    ChainFormNotifier formNotifier,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final dateStr = '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.year}';
      _dateController.text = dateStr;
      formNotifier.setDate(dateStr);
    }
  }

  Future<void> _showManualSelectionSheet(
    BuildContext context,
    ChainFormNotifier formNotifier,
    ChainFormState state,
  ) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Experiences',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('experiences')
                        .where('isActive', isEqualTo: true)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      
                      final allDocs = snapshot.data?.docs ?? [];
                      final targetCity = state.destinationCity.trim().toLowerCase();
                      
                      final docs = allDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final docCity = (data['city'] ?? '').toString().trim().toLowerCase();
                        return docCity == targetCity || docCity.contains(targetCity) || targetCity.contains(docCity);
                      }).toList();

                      if (docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No options available to you in ${state.destinationCity}.',
                            style: AppTypography.bodyMedium,
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final id = docs[index].id;
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                child: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                                    ? Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                                    : Container(width: 50, height: 50, color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.image)),
                              ),
                              title: Text(data['title'] ?? 'Experience', style: AppTypography.labelLarge),
                              subtitle: Text('Rs. ${data['price'] ?? 0}', style: AppTypography.labelSmall),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                                onPressed: () {
                                  int maxAllowed = 4; // default for fullDay
                                  if (state.totalTime == ChainDuration.halfDay) maxAllowed = 2;
                                  if (state.totalTime == ChainDuration.weekend) maxAllowed = 8;

                                  if (state.experiences.length >= maxAllowed) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('You can only select up to $maxAllowed experiences for a ${state.totalTime.label}.'),
                                        backgroundColor: AppColors.warning,
                                      ),
                                    );
                                    return;
                                  }

                                  final exp = ChainExperience(
                                    experienceId: id,
                                    title: data['title'] ?? '',
                                    startTime: data['startTime'] ?? '09:00',
                                    endTime: data['endTime'] ?? '11:00',
                                    duration: (data['duration'] ?? 2).toDouble(),
                                    price: (data['price'] ?? 0).toDouble(),
                                    isOvernight: data['isOvernight'] ?? false,
                                    imageUrl: data['imageUrl'] ?? '',
                                    category: data['category'] ?? '',
                                    hostId: data['hostId'] ?? '',
                                  );
                                  formNotifier.addExperience(exp);
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Experience Added!')),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}