import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../widgets/admin_experience_detail_sheet.dart';

class AdminExperiencesScreen extends StatefulWidget {
  const AdminExperiencesScreen({super.key});

  @override
  State<AdminExperiencesScreen> createState() => _AdminExperiencesScreenState();
}

class _AdminExperiencesScreenState extends State<AdminExperiencesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Active Experiences'),
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildExperiencesList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surface,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by title or host...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        onChanged: (val) {
          setState(() {
            _searchQuery = val.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildExperiencesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('experiences')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading experiences: ${snapshot.error}',
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.explore_off, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No experiences found.',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        // Apply client-side filtering
        final filteredDocs = docs.where((doc) {
          if (_searchQuery.isEmpty) return true;
          final data = doc.data() as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();
          final hostName = (data['hostName'] ?? '').toString().toLowerCase();
          return title.contains(_searchQuery) || hostName.contains(_searchQuery);
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(
            child: Text('No experiences match your search.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildExperienceCard(context, doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildExperienceCard(BuildContext context, String id, Map<String, dynamic> data) {
    final title = data['title'] ?? 'Untitled';
    final hostName = data['hostName'] ?? 'Unknown Host';
    final price = data['price']?.toString() ?? '0';
    final coverImage = data['coverImage'] ?? '';
    final isActive = data['isActive'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetailSheet(context, id, data),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              width: 120,
              height: 120,
              child: coverImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: coverImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[300]),
                      errorWidget: (context, url, err) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              'Inactive',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.error),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Host: $hostName',
                      style: AppTypography.bodySmallSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '\$$price',
                      style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetailSheet(BuildContext context, String id, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AdminExperienceDetailSheet(experienceId: id, data: data),
    );
  }
}
