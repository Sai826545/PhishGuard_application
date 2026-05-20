import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/storage/secure_storage.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final storage = ref.read(secureStorageProvider);
    final isLoggedIn = await storage.isLoggedIn();

    if (!mounted) return;
    if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // Background grid pattern
              Positioned.fill(
                child: CustomPaint(painter: _GridPainter()),
              ),

              // Glowing circles (decorative)
              Positioned(
                top: -80,
                right: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.05),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -60,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(0.04),
                  ),
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Colors.black,
                          size: 60,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App name
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            AppStrings.appName,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.tagline,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Loading indicator at bottom
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Initializing security engine...',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.3)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
