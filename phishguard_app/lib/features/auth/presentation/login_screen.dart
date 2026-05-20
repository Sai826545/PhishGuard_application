import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';
import 'package:phishguard_app/features/auth/data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).login(
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
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.danger,
          ),
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
                  const SizedBox(height: 32),

                  // Logo
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.shield_rounded, color: Colors.black, size: 36),
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 40),

                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

                  const SizedBox(height: 8),

                  Text(
                    'Sign in to PhishGuard to continue your protection.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 40),

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
                    hint: '••••••••',
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

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        AppStrings.forgotPassword,
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ).animate().fadeIn(delay: 550.ms),

                  const SizedBox(height: AppSizes.paddingMD),

                  // Login button
                  PGButton(
                    label: AppStrings.signIn,
                    onPressed: _login,
                    isLoading: isLoading,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),

                  const SizedBox(height: AppSizes.paddingXL),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.dontHaveAccount,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
