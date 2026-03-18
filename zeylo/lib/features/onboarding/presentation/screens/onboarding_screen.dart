import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../widgets/onboarding_page.dart';

/// Onboarding screen with carousel of 3 pages
///
/// Displays a PageView with onboarding pages and navigation buttons
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/illustrations/onboarding1.png',
      'title': 'Welcome to Zeylo',
      'subtitle': 'Discover unique experiences and connect with local communities',
    },
    {
      'image': 'assets/illustrations/onboarding2.png',
      'title': 'Discover Local Experiences',
      'subtitle': 'Find and book amazing activities and experiences near you',
    },
    {
      'image': 'assets/illustrations/onboarding3.png',
      'title': 'Connect & Explore',
      'subtitle': 'Meet new people and share your favorite moments together',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.push('/login');
    }
  }

  IconData _getFallbackIcon(String imagePath) {
    if (imagePath.contains('1')) return Icons.explore_outlined;
    if (imagePath.contains('2')) return Icons.search_outlined;
    return Icons.people_outlined;
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // PageView
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _pages.map((page) {
              return OnboardingPage(
                imagePath: page['image']!,
                title: page['title']!,
                subtitle: page['subtitle']!,
              );
            }).toList(),
          ),
        ),
        // Pagination dots
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.primaryLight.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ),
        // Buttons
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Sign Up button
              ZeyloButton(
                onPressed: () => context.push('/signup'),
                label: 'Sign Up',
                variant: ButtonVariant.filled,
              ),
              const SizedBox(height: AppSpacing.md),
              // Log In button
              ZeyloButton(
                onPressed: () => context.push('/login'),
                label: 'Log In',
                variant: ButtonVariant.outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left side: Images and Dots Carousel
        Expanded(
          flex: 1,
          child: Container(
            color: AppColors.surfaceContainerLow,
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: _pages.map((page) {
                    return Image.asset(
                      page['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryLight.withOpacity(0.3),
                                AppColors.primary.withOpacity(0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getFallbackIcon(page['image']!),
                              size: 150,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                // Pagination dots overlaid on image
                Positioned(
                  bottom: AppSpacing.xl,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.5),
                          border: Border.all(
                            color: _currentPage == index ? Colors.transparent : Colors.black12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side: Onboarding text and Buttons
        Expanded(
          flex: 1,
          child: Container(
            color: AppColors.background ?? Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated text changes
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          key: ValueKey<int>(_currentPage),
                          children: [
                            Text(
                              _pages[_currentPage]['title']!,
                              style: AppTypography.displayMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              _pages[_currentPage]['subtitle']!,
                              style: AppTypography.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ) ?? AppTypography.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 56,
                      child: ZeyloButton(
                        onPressed: () => context.push('/signup'),
                        label: 'Sign Up',
                        variant: ButtonVariant.filled,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 56,
                      child: ZeyloButton(
                        onPressed: () => context.push('/login'),
                        label: 'Log In',
                        variant: ButtonVariant.outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;
            if (isDesktop) {
              return _buildDesktopLayout();
            }
            return _buildMobileLayout();
          },
        ),
      ),
    );
  }
}
