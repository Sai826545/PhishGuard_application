import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';
import 'package:phishguard_app/features/auth/data/auth_repository.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).signup(
          _usernameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (_, next) {
      if (next is AuthSuccess) context.go('/home');
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: AppColors.danger),
        );
      }
    });

    final isLoading = authState is AuthLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 8),

                  Text(
                    'Join PhishGuard and start protecting yourself today.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 32),

                  // Username
                  PGTextField(
                    controller: _usernameCtrl,
                    label: AppStrings.username,
                    hint: 'Enter username',
                    prefix: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                    validator: (v) {
                      if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                      if (v.length < 3) return 'Username must be at least 3 characters';
                      return null;
                    },
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                  const SizedBox(height: AppSizes.paddingMD),

                  // Email
                  PGTextField(
                    controller: _emailCtrl,
                    label: AppStrings.email,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefix: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                    validator: (v) {
                      if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                      if (!v.contains('@')) return AppStrings.invalidEmail;
                      return null;
                    },
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: AppSizes.paddingMD),

                  // Password
                  PGTextField(
                    controller: _passwordCtrl,
                    label: AppStrings.password,
                    hint: 'Min. 6 characters',
                    obscureText: _obscurePassword,
                    prefix: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                      if (v.length < 6) return AppStrings.weakPassword;
                      return null;
                    },
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                  const SizedBox(height: AppSizes.paddingMD),

                  // Confirm password
                  PGTextField(
                    controller: _confirmPasswordCtrl,
                    label: 'Confirm Password',
                    hint: 'Re-enter password',
                    obscureText: _obscureConfirm,
                    prefix: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                      if (v != _passwordCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

                  const SizedBox(height: AppSizes.paddingXL),

                  // Signup button
                  PGButton(
                    label: AppStrings.createAccount,
                    onPressed: _signup,
                    isLoading: isLoading,
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: AppSizes.paddingXL),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
