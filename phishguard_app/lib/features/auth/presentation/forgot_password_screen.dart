import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/network/api_client.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  
  bool _otpSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.post('/auth/forgot-password?email=${Uri.encodeQueryComponent(_emailCtrl.text.trim())}');
      
      if (mounted) {
        setState(() {
          _otpSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Verification code sent! Please check your terminal console logs.'),
            backgroundColor: AppColors.safe,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().contains('400') ? 'Email is not registered.' : 'Failed to send OTP. Please try again.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.post('/auth/reset-password', data: {
        'email': _emailCtrl.text.trim(),
        'otp': _otpCtrl.text.trim(),
        'newPassword': _passwordCtrl.text,
      });

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Password reset successful! You can now log in.'),
            backgroundColor: AppColors.safe,
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().contains('400') ? 'Invalid or expired OTP code.' : 'Failed to reset password.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 24),
                  
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () {
                      if (_otpSent) {
                        setState(() => _otpSent = false);
                      } else {
                        context.go('/login');
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),

                  // Logo / Shield
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
                      child: const Icon(Icons.lock_reset, color: Colors.black, size: 36),
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 40),

                  Text(
                    _otpSent ? 'Reset Password' : 'Forgot Password',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 8),

                  Text(
                    _otpSent 
                        ? 'Enter the 6-digit OTP code sent to your email and your new secure password.'
                        : 'Enter your registered email address below. We will send you a 6-digit OTP to reset your password.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 40),

                  if (!_otpSent) ...[
                    // Email Input
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
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                    const SizedBox(height: AppSizes.paddingXL),

                    // Request OTP button
                    PGButton(
                      label: 'Send Verification Code',
                      onPressed: _requestOtp,
                      isLoading: _isLoading,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                  ] else ...[
                    // OTP Input
                    PGTextField(
                      controller: _otpCtrl,
                      label: 'Verification Code (OTP)',
                      hint: '123456',
                      keyboardType: TextInputType.number,
                      prefix: const Icon(Icons.sms_outlined, color: AppColors.textSecondary),
                      validator: (v) {
                        if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                        if (v.trim().length != 6) return 'Verification code must be 6 digits';
                        return null;
                      },
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                    const SizedBox(height: AppSizes.paddingMD),

                    // Password Input
                    PGTextField(
                      controller: _passwordCtrl,
                      label: 'New Password',
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
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                    const SizedBox(height: AppSizes.paddingXL),

                    // Reset Password Button
                    PGButton(
                      label: 'Reset Password',
                      onPressed: _resetPassword,
                      isLoading: _isLoading,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                  ],

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
