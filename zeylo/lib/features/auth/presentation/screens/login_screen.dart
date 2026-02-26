import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/social_login_button.dart';

/// Login screen for user authentication
///
/// Allows users to log in with email and password or social providers (Google, Apple)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  late GlobalKey<FormState> _formKey;

  String? _nameError;
  String? _phoneError;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _nameError = Validators.validateName(_nameController.text);
      _phoneError = Validators.validatePhone(_phoneController.text);
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
    });

    if (_nameError == null &&
        _phoneError == null &&
        _emailError == null &&
        _passwordError == null) {
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
    }
  }

  Future<void> _signInWithGoogle() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      await authNotifier.signInWithGoogle();

      if (mounted) {
        context.go('/email-otp-request');
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

  Future<void> _signInWithApple() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      await authNotifier.signInWithApple();

      if (mounted) {
        context.go('/email-otp-request');
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
              // Form fields
              ZeyloTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: _nameController,
                errorText: _nameError,
                onChanged: (_) {
                  setState(() {
                    _nameError = null;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              PhoneInputField(
                label: 'Mobile Number',
                controller: _phoneController,
                errorText: _phoneError,
                onChanged: (_) {
                  setState(() {
                    _phoneError = null;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),
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
              // Apple login button
              SocialLoginButton(
                label: 'Login with Apple',
                icon: const Icon(
                  Icons.apple,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onTap: isLoading ? null : _signInWithApple,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppSpacing.md),
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
