import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/home_provider.dart';

/// Glassmorphism search bar widget for the home screen
class HomeSearchBar extends ConsumerStatefulWidget {
  final VoidCallback? onSearchTap;

  const HomeSearchBar({
    this.onSearchTap,
    super.key,
  });

  @override
  ConsumerState<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends ConsumerState<HomeSearchBar> {
  late TextEditingController _controller;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClear = _controller.text.isNotEmpty;
    });
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  void _performSearch() {
    final query = _controller.text.trim();
    ref.read(searchQueryProvider.notifier).state = query;
    widget.onSearchTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
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
            onSubmitted: (_) => _performSearch(),
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search experiences...',
              hintStyle: AppTypography.bodyMediumSecondary.copyWith(
                color: AppColors.textHint,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.sm,
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: AppColors.primary.withOpacity(0.7),
                  size: 22,
                ),
              ),
              suffixIcon: _showClear
                  ? GestureDetector(
                      onTap: _clearSearch,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: AppSpacing.lg,
                          left: AppSpacing.sm,
                        ),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.textHint.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 14,
                          ),
                        ),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
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
}
