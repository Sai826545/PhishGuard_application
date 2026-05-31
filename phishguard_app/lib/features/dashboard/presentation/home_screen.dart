import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/network/api_client.dart';
import 'package:phishguard_app/core/storage/secure_storage.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';
import 'package:phishguard_app/features/dashboard/presentation/scam_map_widget.dart';

// Dashboard repository
final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/dashboard/stats');
  return response.data['data'] as Map<String, dynamic>;
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final storage = ref.read(secureStorageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.card,
        onRefresh: () async => ref.refresh(dashboardProvider),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: AppColors.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.surface, AppColors.background],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
                  child: dashboardAsync.when(
                    data: (data) => Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_getGreeting()}, 👋',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                data['username'] ?? 'User',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Notification bell
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ),
              ),
            ),

            // Body
            SliverPadding(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              sliver: dashboardAsync.when(
                loading: () => SliverList(
                  delegate: SliverChildListDelegate([
                    const PGLoadingCard(height: 140),
                    const SizedBox(height: 12),
                    const PGLoadingCard(height: 100),
                    const SizedBox(height: 12),
                    const PGLoadingCard(height: 200),
                  ]),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: PGEmptyState(
                    title: 'Connection Error',
                    subtitle: 'Could not load dashboard. Check your connection.',
                    icon: Icons.wifi_off_outlined,
                    onAction: () => ref.refresh(dashboardProvider),
                    actionLabel: 'Retry',
                  ),
                ),
                data: (data) => SliverList(
                  delegate: SliverChildListDelegate([
                    _SecurityScoreCard(
                      score: data['securityScore'] as int? ?? 75,
                      totalScans: data['totalScans'] as int? ?? 0,
                      blockedThreats: data['blockedThreats'] as int? ?? 0,
                    ),

                    const SizedBox(height: 20),

                    // Cyber tip banner
                    _CyberTipBanner(tip: data['dailyCybertip'] as String? ?? ''),

                    const SizedBox(height: 20),

                    // Live Threat Map
                    const ScamMapWidget(),

                    const SizedBox(height: 20),

                    // Quick Actions
                    Text(
                      AppStrings.quickActions,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _QuickActionGrid(),

                    const SizedBox(height: 24),

                    // Latest Alerts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.latestAlerts,
                            style: Theme.of(context).textTheme.titleLarge),
                        TextButton(
                          onPressed: () => context.go('/alerts'),
                          child: const Text('See All',
                              style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (data['latestAlerts'] != null)
                      ...((data['latestAlerts'] as List).map((a) =>
                          _AlertCard(alert: a as Map<String, dynamic>))),

                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityScoreCard extends StatelessWidget {
  final int score;
  final int totalScans;
  final int blockedThreats;

  const _SecurityScoreCard({
    required this.score,
    required this.totalScans,
    required this.blockedThreats,
  });

  @override
  Widget build(BuildContext context) {
    return PGCard(
      color: AppColors.card,
      child: Row(
        children: [
          // Score meter
          RiskMeter(score: 100 - score, size: 100),

          const SizedBox(width: AppSizes.paddingMD),

          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.securityScore,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Row(
                  children: [
                    Text(
                      '$score%',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.safe,
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.safeBg,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: const Text(
                        '✓ Protected',
                        style: TextStyle(color: AppColors.safe, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatChip(
                      label: 'Scans',
                      value: '$totalScans',
                      icon: Icons.qr_code_scanner_outlined,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      label: 'Blocked',
                      value: '$blockedThreats',
                      icon: Icons.block_outlined,
                      color: AppColors.danger,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2);
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CyberTipBanner extends StatelessWidget {
  final String tip;

  const _CyberTipBanner({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.accent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.cyberTip,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.isEmpty ? 'Never share your OTP with anyone.' : tip.replaceAll('💡 ', ''),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}

class _QuickActionGrid extends StatelessWidget {
  final List<_QuickAction> actions = const [
    _QuickAction('Scan URL', Icons.link, '/scan/url', AppColors.danger),
    _QuickAction('QR Scan', Icons.qr_code_scanner, '/scan/qr', AppColors.warning),
    _QuickAction('SMS Scan', Icons.sms_outlined, '/scan/sms', AppColors.info),
    _QuickAction('Email Scan', Icons.email_outlined, '/scan/email', AppColors.accent),
    _QuickAction('History', Icons.history, '/history', AppColors.primary),
    _QuickAction('Report', Icons.report_outlined, '/settings/report', AppColors.dangerLight),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) => _QuickActionCard(action: actions[i], index: i),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final String route;
  final Color color;

  const _QuickAction(this.label, this.icon, this.route, this.color);
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;
  final int index;

  const _QuickActionCard({required this.action, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(action.route),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, color: action.color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }
}

class _AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final severity = alert['severity'] as String? ?? 'MEDIUM';
    final color = AppColors.severityColor(severity);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PGCard(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert['title'] as String? ?? 'Alert',
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert['category'] as String? ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            SeverityChip(severity: severity),
          ],
        ),
      ),
    );
  }
}
