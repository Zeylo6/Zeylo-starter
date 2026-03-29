import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/home_provider.dart';

/// Full glassmorphism search bar
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
  bool _isFocused = false;

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
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(_isFocused ? 0.65 : 0.5),
                Colors.white.withOpacity(_isFocused ? 0.45 : 0.28),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary.withOpacity(0.35)
                  : Colors.white.withOpacity(0.65),
              width: _isFocused ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _isFocused ? 20 : 12,
                offset: const Offset(0, 4),
              ),
              if (_isFocused)
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 30,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Focus(
            onFocusChange: (focused) {
              setState(() => _isFocused = focused);
            },
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(),
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search experiences...',
                hintStyle: AppTypography.bodyMediumSecondary.copyWith(
                  color: AppColors.textHint.withOpacity(0.8),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.sm,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.search_rounded,
                      color: _isFocused
                          ? AppColors.primary
                          : AppColors.textHint.withOpacity(0.7),
                      size: 22,
                    ),
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: 4, sigmaY: 4),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AppColors.textHint
                                      .withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textSecondary,
                                  size: 14,
                                ),
                              ),
                            ),
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
      ),
    );
  }
}
