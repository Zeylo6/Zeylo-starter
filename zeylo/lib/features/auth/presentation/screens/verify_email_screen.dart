import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

/// Email verification screen
///
/// Allows users to enter a 5-digit verification code sent to their email
class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(5, (_) => FocusNode());
    _controllers = List.generate(5, (_) => TextEditingController());

    if (widget.email.trim().isEmpty ||
        FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete sign-in and request OTP first.'),
            backgroundColor: AppColors.error,
          ),
        );
        context.go('/login');
      });
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 4) {
      // Move to next field
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  Future<void> _verifyEmail() async {
    final code = _controllers.map((c) => c.text).join();

    if (code.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 5 digits'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.verifyEmail(code: code, email: widget.email);

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendEmail() async {
    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.resendVerificationEmail(widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/onboarding');
            }
          },
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              // Title
              Text(
                'Verify Your Email',
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Subtitle
              Text(
                'We sent an OTP to ${widget.email}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter the 5 digit code that mentioned in the email',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              // Code input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (index) => _buildCodeField(index),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              // Verify button
              ZeyloButton(
                onPressed: _isLoading ? null : _verifyEmail,
                label: 'Verify',
                isLoading: _isLoading,
                variant: ButtonVariant.filled,
              ),
              const SizedBox(height: AppSpacing.massive),
              // Resend link
              Center(
                child: GestureDetector(
                  onTap: _resendEmail,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Haven't got the email yet? ",
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Resend email',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeField(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.border,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        style: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimary,
        ),
        onChanged: (value) => _onCodeChanged(value, index),
      ),
    );
  }
}
