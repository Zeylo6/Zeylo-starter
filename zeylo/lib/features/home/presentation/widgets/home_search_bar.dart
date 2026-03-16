import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/home_provider.dart';

/// Search bar widget for the home screen
///
/// Features:
/// - Rounded text field
/// - Search icon on the left
/// - Clear button when text is entered
/// - Updates search query in the provider
class HomeSearchBar extends ConsumerStatefulWidget {
  /// Callback when search is triggered
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
  late FocusNode _focusNode;
  bool _showClear = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
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
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 500;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: _isFocused ? AppColors.primary : AppColors.border.withOpacity(0.5),
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(),
              style: AppTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: isDesktop 
                    ? 'Search experiences, events, or connections...' 
                    : 'Search...',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textHint,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.sm,
                  ),
                  child: Icon(
                    Icons.search,
                    color: _isFocused ? AppColors.primary : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_showClear)
                      GestureDetector(
                        onTap: _clearSearch,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          child: Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    if (isDesktop)
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0, top: 4.0, bottom: 4.0),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _performSearch,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded, 
                                color: Colors.white, 
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: AppSpacing.sm),
                  ],
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 16.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
