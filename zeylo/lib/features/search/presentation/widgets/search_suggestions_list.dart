import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/providers/home_provider.dart';

/// Search suggestions widget
///
/// Displays relevant suggestions based on search query
class SearchSuggestionsList extends ConsumerWidget {
  /// Search query
  final String query;

  const SearchSuggestionsList({
    required this.query,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(experiencesByFilterProvider).when(
          data: (experiences) {
            // Results are already filtered by Firestore via searchQueryProvider
            final suggestions = experiences.take(8).toList();

            if (suggestions.isEmpty) {
              return Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No suggestions found',
                    style: AppTypography.bodyMediumSecondary,
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggestions',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final experience = suggestions[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      leading: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      title: Text(
                        experience.title,
                        style: AppTypography.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        experience.category,
                        style: AppTypography.bodySmallSecondary,
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/experience-detail',
                          arguments: experience.id,
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Text(
            'Error loading suggestions',
            style: AppTypography.bodySmallSecondary,
          ),
        );
  }
}
