import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.link_outlined,
      iconColor: AppColors.danger,
      title: AppStrings.onboard1Title,
      description: AppStrings.onboard1Desc,
      gradient: AppColors.dangerGradient,
    ),
    _OnboardingData(
      icon: Icons.qr_code_scanner,
      iconColor: AppColors.warning,
      title: AppStrings.onboard2Title,
      description: AppStrings.onboard2Desc,
      gradient: LinearGradient(
        colors: [AppColors.warning, AppColors.accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _OnboardingData(
      icon: Icons.shield_moon_outlined,
      iconColor: AppColors.primary,
      title: AppStrings.onboard3Title,
      description: AppStrings.onboard3Desc,
      gradient: AppColors.primaryGradient,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) => _buildPage(_pages[i], i),
                ),
              ),

              // Indicators + buttons
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingXL),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: 300.ms,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? AppColors.primary
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXL),

                    // Action button
                    PGButton(
                      label: _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          context.go('/login');
                        } else {
                          _pageController.nextPage(
                            duration: 400.ms,
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      icon: Icon(
                        _currentPage == _pages.length - 1
                            ? Icons.rocket_launch_outlined
                            : Icons.arrow_forward_rounded,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with glow
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: data.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: data.iconColor.withOpacity(0.3),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(data.icon, color: Colors.white, size: 64),
          )
              .animate(key: ValueKey('icon_$index'))
              .scale(delay: 100.ms, duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 48),

          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('title_$index'))
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.3),

          const SizedBox(height: AppSizes.paddingMD),

          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('desc_$index'))
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.3),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Gradient gradient;

  _OnboardingData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
