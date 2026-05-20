import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_app/core/router/app_router.dart';
import 'package:phishguard_app/core/theme/app_theme.dart';

class PhishGuardApp extends ConsumerWidget {
  const PhishGuardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'PhishGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
