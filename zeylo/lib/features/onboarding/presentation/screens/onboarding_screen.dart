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
  const OnboardingScreen({Key? key}) : super(key: key);

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
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
                    onPressed: () => context.go('/signup'),
                    label: 'Sign Up',
                    variant: ButtonVariant.filled,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Log In button
                  ZeyloButton(
                    onPressed: () => context.go('/login'),
                    label: 'Log In',
                    variant: ButtonVariant.outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
