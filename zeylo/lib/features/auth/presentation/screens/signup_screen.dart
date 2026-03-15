import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
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
          content:
              Text('Please agree to the Terms of Service and Privacy Policy'),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              AppColors.primaryExtraLight.withOpacity(0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                // Logo or Icon Placeholder
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.blur_on_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Join Zeylo',
                  style: AppTypography.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your extraordinary journey today',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Form fields
                ZeyloTextField(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: _nameController,
                  errorText: _nameError,
                  onChanged: (_) => setState(() => _nameError = null),
                ),
                const SizedBox(height: 16),
                ZeyloTextField(
                  label: 'Email Address',
                  hint: 'john@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  onChanged: (_) => setState(() => _emailError = null),
                ),
                const SizedBox(height: 16),
                PhoneInputField(
                  label: 'Mobile Number',
                  controller: _phoneController,
                  errorText: _phoneError,
                  onChanged: (_) => setState(() => _phoneError = null),
                ),
                const SizedBox(height: 16),
                ZeyloTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  errorText: _passwordError,
                  onChanged: (_) => setState(() => _passwordError = null),
                ),
                const SizedBox(height: 16),
                ZeyloTextField(
                  label: 'Confirm Password',
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  errorText: _confirmPasswordError,
                  onChanged: (_) => setState(() => _confirmPasswordError = null),
                ),
                const SizedBox(height: 32),

                // Role Selector
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'I am joining as a...',
                    style: AppTypography.titleMedium,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.0,
                  children: [
                    _buildRoleCard('seeker', '🔍', 'Seeker', 'Discover'),
                    _buildRoleCard('host', '🏡', 'Host', 'List'),
                    _buildRoleCard('business', '💼', 'Business', 'Group'),
                    _buildRoleCard('admin', '🛡️', 'Admin', 'Manage'),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Terms checkbox
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to the ',
                            style: AppTypography.caption,
                            children: [
                              TextSpan(
                                text: 'Terms',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' & '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Sign up button
                SizedBox(
                  width: double.infinity,
                  child: ZeyloButton(
                    onPressed: isLoading ? null : _validateAndSubmit,
                    label: 'Create Account',
                    isLoading: isLoading,
                    variant: ButtonVariant.filled,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or', style: AppTypography.labelSmall.copyWith(color: AppColors.textHint)),
                    ),
                    Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Google sign up button
                SocialLoginButton(
                  label: 'Google',
                  icon: const Icon(Icons.g_mobiledata, color: AppColors.textPrimary, size: 32),
                  onTap: isLoading ? null : _signUpWithGoogle,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 32),
                
                // Login link
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryExtraLight : AppColors.divider,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTypography.labelSmall.copyWith(fontSize: 9),
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
