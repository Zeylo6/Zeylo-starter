import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';

/// Splash screen shown on app startup
///
/// Displays a branded splash animation and checks auth state
/// to navigate to appropriate screen (home, onboarding, or welcome)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _showSplash();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showSplash() async {
    // Show splash1 for 1 second
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Animate to splash2
    await _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    // Wait for 1 second on splash2
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Check auth state and navigate
    _navigateBasedOnAuthState();
  }

  void _navigateBasedOnAuthState() {
    final authState = ref.read(authStateProvider);

    authState.whenData((user) {
      if (user != null) {
        // User is logged in, go to home
        context.go('/home');
      } else {
        // User is not logged in, check if first launch
        // For now, go to onboarding
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Splash 1: Purple background with white "Z" logo
          Container(
            color: AppColors.primary,
            child: Center(
              child: Text(
                'Z',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 80,
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Splash 2: White background with purple "ZEYLO" text
          Container(
            color: AppColors.background,
            child: Center(
              child: Text(
                'ZEYLO',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 48,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
