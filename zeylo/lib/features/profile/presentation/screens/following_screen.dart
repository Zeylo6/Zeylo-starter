import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/host_avatar.dart';
import '../providers/profile_provider.dart';

/// Following list screen
class FollowingScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const FollowingScreen({
    required this.userId,
    required this.userName,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends ConsumerState<FollowingScreen> {
  final _searchController = TextEditingController();
  late String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final followingAsync = ref.watch(followingProvider(widget.userId));

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
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
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
              hint: 'Search following',
              controller: _searchController,
              prefixWidget: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Following list
          Expanded(
            child: followingAsync.when(
              data: (following) {
                final filtered = following
                    .where((f) => f.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Not following anyone'
                          : 'No results found',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    return _FollowingTile(
                      user: user,
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

/// Individual following tile
class _FollowingTile extends ConsumerStatefulWidget {
  final dynamic user;
  final String userId;

  const _FollowingTile({
    required this.user,
    required this.userId,
  });

  @override
  ConsumerState<_FollowingTile> createState() => _FollowingTileState();
}

class _FollowingTileState extends ConsumerState<_FollowingTile> {
  bool _isFollowing = true;

  Future<void> _toggleFollow() async {
    setState(() {
      _isFollowing = !_isFollowing;
    });

    ref.invalidate(
      followActionProvider((
        widget.userId,
        widget.user.id,
        !_isFollowing,
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
            imageUrl: widget.user.photoUrl,
            hostName: widget.user.name,
            size: AvatarSize.medium,
          ),
          const SizedBox(width: AppSpacing.md),

          // Name
          Expanded(
            child: Text(
              widget.user.name,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
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
                    _isFollowing ? AppColors.primary : AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: Text(
                _isFollowing ? 'Following' : 'Follow',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textInverse,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
