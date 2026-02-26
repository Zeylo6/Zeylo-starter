import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class EmailOtpRequestScreen extends ConsumerStatefulWidget {
  const EmailOtpRequestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EmailOtpRequestScreen> createState() =>
      _EmailOtpRequestScreenState();
}

class _EmailOtpRequestScreenState extends ConsumerState<EmailOtpRequestScreen> {
  late final TextEditingController _emailController;
  bool _isLoading = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    _emailController = TextEditingController(
      text: currentUser?.email ?? '',
    );
    _ensureSignedIn();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _ensureSignedIn() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      try {
        user = await FirebaseAuth.instance.authStateChanges().first.timeout(
          const Duration(seconds: 5),
        );
      } catch (_) {
        user = null;
      }
    }

    if (!mounted) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in first.'),
          backgroundColor: AppColors.error,
        ),
      );
      context.go('/login');
      return;
    }

    if (_emailController.text.trim().isEmpty && (user.email ?? '').isNotEmpty) {
      _emailController.text = user.email!;
    }
  }

  Future<void> _sendOtp() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: AppColors.error,
          ),
        );
        context.go('/login');
      }
      return;
    }

    setState(() {
      _emailError = Validators.validateEmail(_emailController.text.trim());
    });

    if (_emailError != null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      await ref.read(authNotifierProvider.notifier).sendOtpToEmail(email);

      if (mounted) {
        context.go('/verify-email?email=$email');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Enter Email',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Enter the Gmail address where we should send your OTP code.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ZeyloTextField(
              label: 'Email Address',
              hint: 'name@gmail.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
              onChanged: (_) {
                if (_emailError != null) {
                  setState(() {
                    _emailError = null;
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            ZeyloButton(
              onPressed: _isLoading ? null : _sendOtp,
              label: 'Send OTP',
              isLoading: _isLoading,
              variant: ButtonVariant.filled,
            ),
          ],
        ),
      ),
    );
  }
}
