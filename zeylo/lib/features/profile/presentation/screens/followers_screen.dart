import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/host_avatar.dart';
import '../providers/profile_provider.dart';

/// Followers list screen
class FollowersScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const FollowersScreen({
    required this.userId,
    required this.userName,
    super.key,
  });

  @override
  ConsumerState<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends ConsumerState<FollowersScreen> {
  final _searchController = TextEditingController();
  late String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final followersAsync = ref.watch(followersProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.userName,
          style: AppTypography.titleLarge,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ZeyloTextField(
              label: 'Search',
              hint: 'Search followers',
              controller: _searchController,
              prefixWidget: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Followers list
          Expanded(
            child: followersAsync.when(
              data: (followers) {
                final filtered = followers
                    .where((f) => f.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty ? 'No followers' : 'No results found',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final follower = filtered[index];
                    return _FollowerTile(
                      follower: follower,
                      userId: widget.userId,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual follower tile
class _FollowerTile extends ConsumerStatefulWidget {
  final dynamic follower;
  final String userId;

  const _FollowerTile({
    required this.follower,
    required this.userId,
  });

  @override
  ConsumerState<_FollowerTile> createState() => _FollowerTileState();
}

class _FollowerTileState extends ConsumerState<_FollowerTile> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    final result = await ref.read(profileRepositoryProvider).isFollowing(
          widget.userId,
          widget.follower.id,
        );

    result.fold(
      (failure) {},
      (isFollowing) {
        if (mounted) {
          setState(() {
            _isFollowing = isFollowing;
          });
        }
      },
    );
  }

  Future<void> _toggleFollow() async {
    final newFollowState = !_isFollowing;
    setState(() {
      _isFollowing = newFollowState;
    });

    ref.invalidate(
      followActionProvider((
        widget.userId,
        widget.follower.id,
        newFollowState,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Avatar
          HostAvatar(
            imageUrl: widget.follower.photoUrl,
            hostName: widget.follower.name,
            size: AvatarSize.medium,
          ),
          const SizedBox(width: AppSpacing.md),

          // Name
          Expanded(
            child: Text(
              widget.follower.name,
              style: AppTypography.labelLarge,
            ),
          ),

          // Follow button
          SizedBox(
            height: 36,
            width: 100,
            child: ElevatedButton(
              onPressed: _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isFollowing ? AppColors.surface : AppColors.primary,
                side: _isFollowing
                    ? const BorderSide(color: AppColors.border)
                    : BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: Text(
                _isFollowing ? 'Following' : 'Follow',
                style: AppTypography.labelSmall.copyWith(
                  color: _isFollowing ? AppColors.textPrimary : AppColors.textInverse,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
