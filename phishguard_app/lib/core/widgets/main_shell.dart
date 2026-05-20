import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/scan')) return 1;
    if (location.startsWith('/history')) return 2;
    if (location.startsWith('/alerts')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: AppSizes.bottomNavHeight,
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primary.withOpacity(0.15),
            selectedIndex: _currentIndex(context),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              switch (index) {
                case 0: context.go('/home'); break;
                case 1: context.go('/scan'); break;
                case 2: context.go('/history'); break;
                case 3: context.go('/alerts'); break;
                case 4: context.go('/settings'); break;
              }
            },
            destinations: [
              _buildDestination(Icons.shield_outlined, Icons.shield, AppStrings.home, 0, context),
              _buildDestination(Icons.qr_code_scanner_outlined, Icons.qr_code_scanner, AppStrings.scan, 1, context),
              _buildDestination(Icons.history_outlined, Icons.history, AppStrings.history, 2, context),
              _buildDestination(Icons.notifications_outlined, Icons.notifications, AppStrings.alerts, 3, context),
              _buildDestination(Icons.settings_outlined, Icons.settings, AppStrings.settings, 4, context),
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildDestination(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
    BuildContext context,
  ) {
    return NavigationDestination(
      icon: Icon(icon, size: 22, color: AppColors.textDisabled),
      selectedIcon: Icon(activeIcon, size: 22, color: AppColors.primary),
      label: label,
    );
  }
}
