import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/moment_entity.dart';
import '../providers/community_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MomentsBar extends ConsumerWidget {
  const MomentsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final momentsAsync = ref.watch(momentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Moments',
                style: AppTypography.titleMedium,
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all moments or reveal history
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: momentsAsync.when(
            data: (moments) {
              // Group moments by user if needed, or just show unique users with new moments
              // For simplicity, showing individual moments for now

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                scrollDirection: Axis.horizontal,
                itemCount: moments.length + 1, // +1 for "Add Moment"
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildAddMomentButton(context, ref);
                  }

                  final moment = moments[index - 1];
                  return _buildMomentItem(context, moment);
                },
              );
            },
            loading: () => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) => _buildShimmerItem(),
            ),
            error: (error, _) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMomentButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your Moment',
            style: AppTypography.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildMomentItem(BuildContext context, Moment moment) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: GestureDetector(
        onTap: () {
          // TODO: Open story viewer
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      CachedNetworkImageProvider(moment.userAvatar),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              moment.userName.split(' ')[0],
              style: AppTypography.labelSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: 40,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
