import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../widgets/search_suggestions_list.dart';

/// Search screen with auto-suggestions
///
/// Features:
/// - Search input field with clear button
/// - Auto-suggestions based on recent searches and categories
/// - Quick category filters
/// - Navigation to search results
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _controller;
  List<String> _recentSearches = [
    'Hiking',
    'Cooking class',
    'Meditation',
    'Art workshop',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.textPrimary,
        ),
        title: Text(
          'Search',
          style: AppTypography.headlineSmall,
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search input field
                _buildSearchInput(),
                const SizedBox(height: AppSpacing.xxl),

                // Recent searches or suggestions
                if (_controller.text.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Searches',
                        style: AppTypography.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildRecentSearches(),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Popular Categories',
                        style: AppTypography.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildCategoryQuickLinks(),
                    ],
                  )
                else
                  SearchSuggestionsList(query: _controller.text),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Material(
      color: Colors.transparent,
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        autofocus: true,
        onSubmitted: _performSearch,
        onChanged: (value) {
          setState(() {});
        },
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search experiences...',
          hintStyle: AppTypography.bodyMediumSecondary,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.sm,
            ),
            child: Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: AppSpacing.md,
                      left: AppSpacing.sm,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: _recentSearches
          .map(
            (search) => GestureDetector(
              onTap: () {
                _controller.text = search;
                setState(() {});
                _performSearch(search);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  search,
                  style: AppTypography.bodySmall,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCategoryQuickLinks() {
    return ref.watch(categoriesProvider).when(
          data: (categories) {
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: categories.take(4).map((category) {
                return GestureDetector(
                  onTap: () {
                    _controller.text = category.name;
                    setState(() {});
                    _performSearch(category.name);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(
                      category.name,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Text('Loading categories...'),
          error: (error, stackTrace) => Text(
            'Failed to load categories',
            style: AppTypography.bodySmallSecondary,
          ),
        );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    // Add to recent searches if not already there
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    }

    // Navigate to search results
    Navigator.of(context).pushNamed(
      '/search-results',
      arguments: query,
    );
  }
}
