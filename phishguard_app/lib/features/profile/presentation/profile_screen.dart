import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/network/api_client.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';
import 'package:intl/intl.dart';

final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/profile');
  return response.data['data'] as Map<String, dynamic>;
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (_, __) => PGEmptyState(
          title: 'Load Error',
          subtitle: 'Could not load profile.',
          icon: Icons.person_off_outlined,
          onAction: () => ref.refresh(profileProvider),
          actionLabel: 'Retry',
        ),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header card
              PGCard(
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (profile['username'] as String? ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 16),

                    Text(
                      profile['username'] as String? ?? 'User',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile['email'] as String? ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    if (profile['joinedDate'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Member since ${_formatDate(profile['joinedDate'] as String)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatBox(
                          label: 'Scans',
                          value: '${profile['totalScans'] ?? 0}',
                          icon: Icons.qr_code_scanner_outlined,
                          color: AppColors.info,
                        ),
                        Container(height: 40, width: 1, color: AppColors.border),
                        _StatBox(
                          label: 'Blocked',
                          value: '${profile['blockedThreats'] ?? 0}',
                          icon: Icons.block_outlined,
                          color: AppColors.danger,
                        ),
                        Container(height: 40, width: 1, color: AppColors.border),
                        _StatBox(
                          label: 'Score',
                          value: '${profile['securityScore'] ?? 75}%',
                          icon: Icons.security_outlined,
                          color: AppColors.safe,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),

              const SizedBox(height: 20),

              // Security score bar
              _SecurityBar(score: profile['securityScore'] as int? ?? 75),

              const SizedBox(height: 20),

              // Achievements
              if (profile['achievementBadges'] != null &&
                  (profile['achievementBadges'] as List).isNotEmpty) ...[
                Text(AppStrings.achievements, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ((profile['achievementBadges'] as List)
                      .cast<String>())
                      .map((badge) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.accent.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('MMMM yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        )),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SecurityBar extends StatelessWidget {
  final int score;

  const _SecurityBar({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 70 ? AppColors.safe : score >= 40 ? AppColors.warning : AppColors.danger;
    final label = score >= 70 ? '🟢 Excellent Protection' : score >= 40 ? '🟡 Moderate Risk' : '🔴 High Risk';

    return PGCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.securityScore, style: Theme.of(context).textTheme.titleMedium),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ).animate().slideX(begin: -1, duration: 800.ms, delay: 200.ms, curve: Curves.easeOut),
          const SizedBox(height: 8),
          Text(
            '$score / 100',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
