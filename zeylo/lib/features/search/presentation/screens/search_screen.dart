import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../widgets/search_suggestions_list.dart';

/// Glassmorphism search screen
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _controller;
  final List<String> _recentSearches = [
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
  void deactivate() {
    ref.read(searchQueryProvider.notifier).state = '';
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3EEFF),
              Color(0xFFF9F7FF),
              Color(0xFFEDE9FE),
              Color(0xFFF5F3FF),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 200,
              left: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            CustomScrollView(
              slivers: [
                // Glass app bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  snap: true,
                  toolbarHeight: 64,
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.5),
                              Colors.white.withOpacity(0.3),
                            ],
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.5),
                              width: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  leading: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0.3),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.7),
                                width: 1.2,
                              ),
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                size: 20, color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Search',
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.w800,
                          )),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchInput(),
                          const SizedBox(height: AppSpacing.xxl),
                          if (_controller.text.isEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionHeader('Recent Searches'),
                                const SizedBox(height: AppSpacing.md),
                                _buildRecentSearches(),
                                const SizedBox(height: AppSpacing.xxl),
                                _sectionHeader('Popular Categories'),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(title,
            style: AppTypography.titleLarge
                .copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildSearchInput() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.28),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.65),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            autofocus: true,
            onSubmitted: _performSearch,
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
              setState(() {});
            },
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search experiences...',
              hintStyle: AppTypography.bodyMediumSecondary.copyWith(
                color: AppColors.textHint.withOpacity(0.8),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(
                    left: AppSpacing.lg, right: AppSpacing.sm),
                child: Icon(Icons.search_rounded,
                    color: AppColors.primary.withOpacity(0.7), size: 22),
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _controller.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: AppSpacing.lg, left: AppSpacing.sm),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.textHint.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded,
                              color: AppColors.textSecondary, size: 14),
                        ),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: _recentSearches.map((search) {
        return GestureDetector(
          onTap: () {
            _controller.text = search;
            setState(() {});
            _performSearch(search);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.55),
                      Colors.white.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.65),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_rounded,
                        size: 14, color: AppColors.textHint),
                    const SizedBox(width: 6),
                    Text(search, style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.12),
                              AppColors.gradientEnd.withOpacity(0.06),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          category.name,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    }

    Navigator.of(context).pushNamed(
      '/search-results',
      arguments: query,
    );
  }
}
