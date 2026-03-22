import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class VerifySuccessScreen extends StatefulWidget {
  const VerifySuccessScreen({super.key});

  @override
  State<VerifySuccessScreen> createState() => _VerifySuccessScreenState();
}

class _VerifySuccessScreenState extends State<VerifySuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();
    _navigateToHome();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3EEFF), Color(0xFFF9F7FF), Color(0xFFEDE9FE), Color(0xFFF5F3FF)],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withOpacity(0.15),
                        AppColors.success.withOpacity(0.06),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.success.withOpacity(0.25), width: 2),
                    boxShadow: [
                      BoxShadow(color: AppColors.success.withOpacity(0.25), blurRadius: 24, spreadRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, color: AppColors.success, size: 56),
                ),
              ),
              const SizedBox(height: 24),
              Text('Email Verified!', style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Your email has been verified successfully', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
