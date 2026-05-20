import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/storage/secure_storage.dart';
import 'package:phishguard_app/features/auth/presentation/splash_screen.dart';
import 'package:phishguard_app/features/auth/presentation/onboarding_screen.dart';
import 'package:phishguard_app/features/auth/presentation/login_screen.dart';
import 'package:phishguard_app/features/auth/presentation/signup_screen.dart';
import 'package:phishguard_app/features/dashboard/presentation/home_screen.dart';
import 'package:phishguard_app/features/scanner/presentation/url_scan_screen.dart';
import 'package:phishguard_app/features/scanner/presentation/qr_scan_screen.dart';
import 'package:phishguard_app/features/scanner/presentation/sms_scan_screen.dart';
import 'package:phishguard_app/features/scanner/presentation/email_scan_screen.dart';
import 'package:phishguard_app/features/scanner/presentation/scan_result_screen.dart';
import 'package:phishguard_app/features/history/presentation/history_screen.dart';
import 'package:phishguard_app/features/alerts/presentation/alerts_screen.dart';
import 'package:phishguard_app/features/report/presentation/report_scam_screen.dart';
import 'package:phishguard_app/features/profile/presentation/profile_screen.dart';
import 'package:phishguard_app/features/settings/presentation/settings_screen.dart';
import 'package:phishguard_app/core/widgets/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final storage = ref.read(secureStorageProvider);
      final isLoggedIn = await storage.isLoggedIn();
      final path = state.uri.path;

      final publicRoutes = ['/splash', '/onboarding', '/login', '/signup'];

      if (!isLoggedIn && !publicRoutes.contains(path)) {
        return '/login';
      }
      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),

      // Main Shell (Bottom Nav)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/scan',
            builder: (_, __) => const UrlScanScreen(),
            routes: [
              GoRoute(path: 'url', builder: (_, __) => const UrlScanScreen()),
              GoRoute(path: 'qr', builder: (_, __) => const QrScanScreen()),
              GoRoute(path: 'sms', builder: (_, __) => const SmsScanScreen()),
              GoRoute(path: 'email', builder: (_, __) => const EmailScanScreen()),
              GoRoute(
                path: 'result',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return ScanResultScreen(result: extra);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/history',
            builder: (_, __) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/alerts',
            builder: (_, __) => const AlertsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
            routes: [
              GoRoute(path: 'profile', builder: (_, __) => const ProfileScreen()),
              GoRoute(path: 'report', builder: (_, __) => const ReportScamScreen()),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Center(
        child: Text(
          'Page not found: ${state.uri.path}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
});
