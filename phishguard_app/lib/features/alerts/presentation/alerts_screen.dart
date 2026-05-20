import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/network/api_client.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';
import 'package:intl/intl.dart';

final alertsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/alerts');
  final items = response.data['data'] as List<dynamic>;
  return items.map((e) => e as Map<String, dynamic>).toList();
});

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  String? _selectedSeverity;

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.alerts)),
      body: Column(
        children: [
          // Severity filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMD,
              vertical: AppSizes.paddingSM,
            ),
            child: Row(
              children: [null, 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'].map((sev) {
                final label = sev ?? 'All';
                final isSelected = _selectedSeverity == sev;
                final color = sev != null ? AppColors.severityColor(sev) : AppColors.primary;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSeverity = sev),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.2) : AppColors.card,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        border: Border.all(color: isSelected ? color : AppColors.border),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? color : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: alertsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              error: (_, __) => PGEmptyState(
                title: 'Connection Error',
                subtitle: 'Could not load threat alerts.',
                icon: Icons.wifi_off_outlined,
                onAction: () => ref.refresh(alertsProvider),
                actionLabel: 'Retry',
              ),
              data: (alerts) {
                final filtered = _selectedSeverity == null
                    ? alerts
                    : alerts.where((a) =>
                        (a['severity'] as String?)?.toUpperCase() == _selectedSeverity,
                      ).toList();

                if (filtered.isEmpty) {
                  return const PGEmptyState(
                    title: 'No Alerts',
                    subtitle: 'No threat alerts for this severity level.',
                    icon: Icons.notifications_off_outlined,
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => ref.refresh(alertsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _AlertDetailCard(
                      alert: filtered[i],
                      index: i,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertDetailCard extends StatelessWidget {
  final Map<String, dynamic> alert;
  final int index;

  const _AlertDetailCard({required this.alert, required this.index});

  @override
  Widget build(BuildContext context) {
    final severity = alert['severity'] as String? ?? 'MEDIUM';
    final color = AppColors.severityColor(severity);
    final category = alert['category'] as String? ?? 'GENERAL';
    final publishedAt = alert['publishedAt'] as String?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PGCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_categoryIcon(category), color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title'] as String? ?? 'Alert',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SeverityChip(severity: severity),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                            ),
                            child: Text(
                              category.replaceAll('_', ' '),
                              style: const TextStyle(
                                color: AppColors.textDisabled,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (alert['description'] != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                alert['description'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.6),
              ),
            ],

            if (publishedAt != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 12, color: AppColors.textDisabled),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(publishedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 60 * index)).fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  IconData _categoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'BANKING': return Icons.account_balance_outlined;
      case 'UPI_PAYMENT': return Icons.payment_outlined;
      case 'COURIER': return Icons.local_shipping_outlined;
      case 'GOVT_SCHEME': return Icons.account_balance;
      case 'KYC': return Icons.verified_user_outlined;
      case 'PHISHING': return Icons.phishing;
      case 'SMS_SCAM': return Icons.sms_failed_outlined;
      default: return Icons.warning_amber_outlined;
    }
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return isoString;
    }
  }
}
