import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeylo/core/theme/app_colors.dart';
import 'package:zeylo/core/theme/app_spacing.dart';
import 'package:zeylo/core/theme/app_typography.dart';
import 'package:zeylo/features/community/presentation/providers/community_provider.dart';
import 'package:zeylo/features/community/presentation/widgets/community_post_card.dart';
import 'package:zeylo/features/profile/domain/entities/user_profile_entity.dart';
import 'package:zeylo/features/profile/presentation/providers/profile_provider.dart';

class AdminUserDetailScreen extends ConsumerWidget {
  final String userId;

  const AdminUserDetailScreen({
    required this.userId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('User Details'),
        elevation: 0,
      ),
      body: profileAsync.when(
        data: (profile) => _buildContent(context, ref, profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, UserProfileEntity profile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(profile),
          const Divider(),
          _buildUserStats(profile),
          const Divider(),
          _buildUserPosts(ref),
        ],
      ),
    );
  }

  Widget _buildUserHeader(UserProfileEntity profile) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: profile.photoUrl != null ? NetworkImage(profile.photoUrl!) : null,
            child: profile.photoUrl == null ? const Icon(Icons.person, size: 40) : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: AppTypography.headlineMedium),
                if (profile.bio != null)
                  Text(profile.bio!, style: AppTypography.bodyMediumSecondary),
                const SizedBox(height: AppSpacing.sm),
                // role is not in UserProfileEntity, we can omit it or fetch it separately
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(UserProfileEntity profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(label: 'Followers', value: profile.followerCount.toString()),
          _StatItem(label: 'Following', value: profile.followingCount.toString()),
        ],
      ),
    );
  }

  Widget _buildUserPosts(WidgetRef ref) {
    final postsAsync = ref.watch(userPostsProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text('User Posts', style: AppTypography.titleLarge),
        ),
        postsAsync.when(
          data: (posts) {
            if (posts.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Text('No posts found'),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, index) {
                return CommunityPostCard(post: posts[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error loading posts: $err')),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.titleLarge),
        Text(label, style: AppTypography.bodySmallSecondary),
      ],
    );
  }
}
