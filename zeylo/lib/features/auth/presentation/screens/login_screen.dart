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
import '../widgets/social_login_button.dart';

/// Login screen for user authentication
///
/// Allows users to log in with email and password or Google
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
    });

    if (_emailError == null && _passwordError == null) {
      _performLogin();
    }
  }

  Future<void> _performLogin() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      await authNotifier.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        // Check if email is verified
        final isVerified =
            ref.read(authRepositoryProvider).isCurrentUserEmailVerified;
        if (isVerified) {
          context.go('/home');
        } else {
          // Send a fresh verification email and redirect to verify screen
          try {
            await authNotifier.sendVerificationEmail();
          } catch (_) {
            // Ignore if send fails (e.g. too many requests) — still navigate
          }
          if (mounted) context.go('/verify-email');
        }
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

  Future<void> _signInWithGoogle() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      await authNotifier.signInWithGoogle();

      if (mounted) {
        final isVerified =
            ref.read(authRepositoryProvider).isCurrentUserEmailVerified;
        if (isVerified) {
          context.go('/home');
        } else {
          try {
            await authNotifier.sendVerificationEmail();
          } catch (_) {}
          if (mounted) context.go('/verify-email');
        }
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

  Future<void> _showForgotPasswordDialog() async {
    final emailController =
        TextEditingController(text: _emailController.text);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address to receive a password reset link.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, emailController.text),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    emailController.dispose();

    if (result != null && result.isNotEmpty && mounted) {
      try {
        await ref.read(authNotifierProvider.notifier).resetPassword(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent. Check your inbox.'),
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
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Back arrow
              GestureDetector(
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
                  size: 24,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Title
              Text(
                'Log In',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              // Email field
              ZeyloTextField(
                label: 'Email Address',
                hint: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                onChanged: (_) {
                  setState(() {
                    _emailError = null;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              // Password field
              ZeyloTextField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passwordController,
                obscureText: true,
                errorText: _passwordError,
                onChanged: (_) {
                  setState(() {
                    _passwordError = null;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              // Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _showForgotPasswordDialog,
                  child: Text(
                    'Forgot Password?',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              // Continue button
              ZeyloButton(
                onPressed: isLoading ? null : _validateAndSubmit,
                label: 'Continue',
                isLoading: isLoading,
                variant: ButtonVariant.filled,
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Divider with text
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.border,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'Or',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.border,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Google login button
              SocialLoginButton(
                label: 'Login with Google',
                icon: const Icon(
                  Icons.g_mobiledata,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                onTap: isLoading ? null : _signInWithGoogle,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppSpacing.massive),
              // Sign up link
              Center(
                child: GestureDetector(
                  onTap: () => context.push('/signup'),
                  child: RichText(
                    text: TextSpan(
                      text: "New to Zeylo? ",
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
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
}
