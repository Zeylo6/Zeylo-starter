import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Screen for joining an experience with user preview
class JoinExperienceScreen extends StatefulWidget {
  /// Experience ID
  final String experienceId;

  /// Experience title
  final String? title;

  const JoinExperienceScreen({
    required this.experienceId,
    this.title,
    super.key,
  });

  @override
  State<JoinExperienceScreen> createState() => _JoinExperienceScreenState();
}

class _JoinExperienceScreenState extends State<JoinExperienceScreen> {
  // Mock participants
  final participants = [
    {'name': 'Shenuka Dias', 'avatar': 'url1'},
    {'name': 'Thenu Sandul', 'avatar': 'url2'},
    {'name': 'Menath Perera', 'avatar': 'url3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Map view placeholder
          _buildMapView(),
          // Add profile button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: () {
                    // Handle add profile
                  },
                  child: Text(
                    'Add Profile',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Participants list
          _buildParticipantsList(),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      height: 250,
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Center(
              child: Icon(
                Icons.map,
                size: 48,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
          ),
          // Location pin (center)
          Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        itemCount: participants.length,
        itemBuilder: (context, index) {
          final participant = participants[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: _buildParticipantTile(participant),
          );
        },
      ),
    );
  }

  Widget _buildParticipantTile(Map<String, String> participant) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: CachedNetworkImage(
                imageUrl: participant['avatar'] ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surface,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Color(0xFFE5E7EB),
                  child: const Icon(Icons.person, size: 24),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Name
          Expanded(
            child: Text(
              participant['name'] ?? '',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Connect button
          GestureDetector(
            onTap: () {
              // Handle connect
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'Connect',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
