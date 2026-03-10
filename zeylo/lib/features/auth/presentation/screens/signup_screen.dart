import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/social_login_button.dart';

/// Sign up screen for user registration
///
/// Allows new users to create an account with email, password, and phone number
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _agreeToTerms = false;
  String _selectedRole = 'seeker'; // Default role

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _nameError = Validators.validateName(_nameController.text);
      _emailError = Validators.validateEmail(_emailController.text);
      _phoneError = Validators.validatePhone(_phoneController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);

      if (_passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = Validators.validatePassword(
          _confirmPasswordController.text,
        );
      }
    });

    if (_nameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _agreeToTerms) {
      _performSignUp();
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service and Privacy Policy'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _performSignUp() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      await authNotifier.signUpWithEmail(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (mounted) {
        context.go('/verify-email');
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

  Future<void> _signUpWithGoogle() async {
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
                'Create Account',
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
              const SizedBox(height: AppSpacing.lg),
              ZeyloTextField(
                label: 'Confirm Password',
                hint: 'Confirm your password',
                controller: _confirmPasswordController,
                obscureText: true,
                errorText: _confirmPasswordError,
                onChanged: (_) {
                  setState(() {
                    _confirmPasswordError = null;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Role Selector
              Text(
                'I am a...',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 2.2,
                children: [
                  _buildRoleCard('seeker', '🔍', 'Seeker', 'Discover experiences'),
                  _buildRoleCard('host', '🏡', 'Host', 'List your experiences'),
                  _buildRoleCard('business', '💼', 'Business', 'Offer group packages'),
                  _buildRoleCard('admin', '🛡️', 'Admin', 'Manage the platform'),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Terms checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _agreeToTerms = !_agreeToTerms;
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'I agree to the ',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: ' and ',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTypography.bodySmall.copyWith(
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
              const SizedBox(height: AppSpacing.xxxl),
              // Sign up button
              ZeyloButton(
                onPressed: isLoading ? null : _validateAndSubmit,
                label: 'Sign Up',
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
              // Google sign up button
              SocialLoginButton(
                label: 'Sign up with Google',
                icon: const Icon(
                  Icons.g_mobiledata,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                onTap: isLoading ? null : _signUpWithGoogle,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              // Login link
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'Log In',
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

  Widget _buildRoleCard(String role, String emoji, String label, String description) {
    final bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.primary.withAlpha(51), AppColors.primary.withAlpha(25)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withAlpha(51), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
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
