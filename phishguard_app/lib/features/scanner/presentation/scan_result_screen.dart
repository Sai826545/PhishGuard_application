import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';
import 'package:phishguard_app/features/auth/domain/models.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanResultScreen extends StatelessWidget {
  final Map<String, dynamic>? result;

  const ScanResultScreen({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.scanResult)),
        body: const PGEmptyState(
          title: 'No Result',
          subtitle: 'No scan result to display.',
          icon: Icons.search_off_outlined,
        ),
      );
    }

    final model = ScanResultModel.fromJson(result!);
    final statusColor = AppColors.statusColor(model.resultStatus);
    final statusBg = AppColors.statusBgColor(model.resultStatus);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.scanResult),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              final text = 'PhishGuard Result: ${model.resultStatus}\n'
                  'Risk Score: ${model.riskScore}/100\n'
                  'URL: ${model.scannedContent}\n'
                  'Reasons:\n${model.aiReasons.join("\n")}';
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Result copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingXL),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  // Animated status icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _statusIcon(model.resultStatus),
                      color: statusColor,
                      size: 44,
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),

                  const SizedBox(height: 16),

                  StatusBadge(status: model.resultStatus, large: true),

                  const SizedBox(height: 16),

                  // Risk score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${model.riskScore}',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      Text(
                        '/100',
                        style: TextStyle(
                          color: statusColor.withOpacity(0.6),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    AppStrings.riskScore,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 12),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: model.riskScore / 100,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 8,
                    ),
                  ).animate().slideX(
                    begin: -1,
                    duration: 800.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Scanned content
            _SectionCard(
              title: 'Scanned Content',
              icon: Icons.link,
              iconColor: AppColors.info,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.scannedContent.length > 200
                        ? '${model.scannedContent.substring(0, 200)}...'
                        : model.scannedContent,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  if (model.scannedContent.startsWith('http')) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.tryParse(model.scannedContent);
                        if (uri != null && model.resultStatus == 'SAFE') {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('⚠️ This link is flagged as dangerous. Opening blocked for safety.'),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_new, size: 14),
                      label: Text(
                        model.resultStatus == 'SAFE' ? 'Open Link' : 'Blocked (Dangerous)',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: model.resultStatus == 'SAFE'
                            ? AppColors.primary
                            : AppColors.danger,
                        side: BorderSide(
                          color: model.resultStatus == 'SAFE'
                              ? AppColors.primary
                              : AppColors.danger,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            // Domain Info
            _SectionCard(
              title: AppStrings.domainInfo,
              icon: Icons.dns_outlined,
              iconColor: AppColors.accent,
              child: Column(
                children: [
                  _InfoRow('Domain', model.domainName ?? 'N/A', Icons.language),
                  _InfoRow(
                    'SSL Certificate',
                    model.sslStatus ? '✅ Valid HTTPS' : '❌ No SSL / HTTP',
                    Icons.lock_outline,
                    valueColor: model.sslStatus ? AppColors.safe : AppColors.danger,
                  ),
                  _InfoRow(
                    'Redirects',
                    '${model.redirectCount}',
                    Icons.swap_horiz,
                    valueColor: model.redirectCount > 2 ? AppColors.warning : AppColors.textPrimary,
                  ),
                  _InfoRow(
                    'Domain Age',
                    model.domainAgeDays < 0
                        ? 'Unknown'
                        : model.domainAgeDays < 30
                            ? '${model.domainAgeDays} days (Very New ⚠️)'
                            : '${model.domainAgeDays} days',
                    Icons.calendar_today_outlined,
                    valueColor: (model.domainAgeDays >= 0 && model.domainAgeDays < 30)
                        ? AppColors.warning
                        : AppColors.textPrimary,
                  ),
                  _InfoRow(
                    'Blacklisted',
                    model.blacklisted ? '🔴 Yes — Known Phishing Site' : '✅ No',
                    Icons.block_outlined,
                    valueColor: model.blacklisted ? AppColors.danger : AppColors.safe,
                  ),
                  _InfoRow(
                    'Trusted Domain',
                    model.trusted ? '✅ Yes — Verified Safe' : 'Not in whitelist',
                    Icons.verified_outlined,
                    valueColor: model.trusted ? AppColors.safe : AppColors.textSecondary,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

            // AI Reasons
            if (model.aiReasons.isNotEmpty)
              _SectionCard(
                title: AppStrings.aiReasons,
                icon: Icons.psychology_outlined,
                iconColor: AppColors.primary,
                child: Column(
                  children: model.aiReasons.map((reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            reason,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              height: 1.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

            // Scan time
            if (model.scannedAt != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    'Scanned on ${DateFormat('dd MMM yyyy, hh:mm a').format(model.scannedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: PGButton(
                    label: 'Scan Again',
                    isOutlined: true,
                    onPressed: () => context.go('/scan'),
                    icon: const Icon(Icons.refresh, size: 16, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PGButton(
                    label: 'View History',
                    onPressed: () => context.go('/history'),
                    icon: const Icon(Icons.history, size: 16, color: Colors.black),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'SAFE': return Icons.check_circle_outline;
      case 'SUSPICIOUS': return Icons.warning_amber_outlined;
      case 'DANGEROUS': return Icons.dangerous_outlined;
      default: return Icons.help_outline;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PGCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, this.icon, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textDisabled),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
