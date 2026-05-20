import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/network/api_client.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';
import 'package:phishguard_app/features/auth/data/auth_repository.dart';

final settingsDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/settings');
  return response.data['data'] as Map<String, dynamic>;
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = true;
  bool _biometric = false;
  bool _notifications = true;
  bool _autoScan = false;
  bool _shareData = false;
  bool _initialized = false;

  void _initSettings(Map<String, dynamic> data) {
    if (_initialized) return;
    _darkMode = data['darkMode'] as bool? ?? true;
    _biometric = data['biometricLogin'] as bool? ?? false;
    _notifications = data['notificationsEnabled'] as bool? ?? true;
    _autoScan = data['autoScanSms'] as bool? ?? false;
    _shareData = data['shareAnonymousData'] as bool? ?? false;
    _initialized = true;
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.put('/settings/update', data: {key: value});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update setting.'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (_, __) => const Center(child: Text('Failed to load settings.')),
        data: (data) {
          _initSettings(data);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile section
                _SettingsSection(
                  title: 'Account',
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      subtitle: 'View stats, achievements',
                      onTap: () => context.go('/settings/profile'),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled),
                    ),
                    _SettingsTile(
                      icon: Icons.report_outlined,
                      title: 'Report a Scam',
                      subtitle: 'Help protect the community',
                      iconColor: AppColors.danger,
                      onTap: () => context.go('/settings/report'),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms),

                // Appearance
                _SettingsSection(
                  title: 'Appearance',
                  children: [
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: AppStrings.darkMode,
                      subtitle: 'Dark cybersecurity theme',
                      trailing: Switch(
                        value: _darkMode,
                        onChanged: (v) {
                          setState(() => _darkMode = v);
                          _updateSetting('darkMode', v);
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 150.ms),

                // Security
                _SettingsSection(
                  title: 'Security',
                  children: [
                    _SettingsTile(
                      icon: Icons.fingerprint,
                      title: AppStrings.biometricLogin,
                      subtitle: 'Use fingerprint to unlock',
                      iconColor: AppColors.primary,
                      trailing: Switch(
                        value: _biometric,
                        onChanged: (v) {
                          setState(() => _biometric = v);
                          _updateSetting('biometricLogin', v);
                        },
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.sms_outlined,
                      title: 'Auto-scan SMS',
                      subtitle: 'Automatically scan incoming SMS',
                      iconColor: AppColors.warning,
                      trailing: Switch(
                        value: _autoScan,
                        onChanged: (v) {
                          setState(() => _autoScan = v);
                          _updateSetting('autoScanSms', v);
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                // Notifications
                _SettingsSection(
                  title: 'Notifications',
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: AppStrings.notifications,
                      subtitle: 'Threat alerts and security tips',
                      trailing: Switch(
                        value: _notifications,
                        onChanged: (v) {
                          setState(() => _notifications = v);
                          _updateSetting('notificationsEnabled', v);
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 250.ms),

                // Language
                _SettingsSection(
                  title: 'Language',
                  children: [
                    _SettingsTile(
                      icon: Icons.language,
                      title: AppStrings.language,
                      subtitle: data['language'] as String? ?? 'en',
                      trailing: DropdownButton<String>(
                        value: data['language'] as String? ?? 'en',
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: AppColors.textPrimary),
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'hi', child: Text('हिंदी')),
                          DropdownMenuItem(value: 'ta', child: Text('தமிழ்')),
                          DropdownMenuItem(value: 'te', child: Text('తెలుగు')),
                          DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
                          DropdownMenuItem(value: 'mr', child: Text('मराठी')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            _updateSetting('language', v);
                            ref.refresh(settingsDataProvider);
                          }
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                // Privacy
                _SettingsSection(
                  title: 'Privacy',
                  children: [
                    _SettingsTile(
                      icon: Icons.analytics_outlined,
                      title: 'Share Anonymous Data',
                      subtitle: 'Help improve threat detection',
                      trailing: Switch(
                        value: _shareData,
                        onChanged: (v) {
                          setState(() => _shareData = v);
                          _updateSetting('shareAnonymousData', v);
                        },
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.delete_outline,
                      title: AppStrings.clearHistory,
                      subtitle: 'Remove all scan records',
                      iconColor: AppColors.danger,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Feature coming soon.')),
                        );
                      },
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled),
                    ),
                  ],
                ).animate().fadeIn(delay: 350.ms),

                // About
                _SettingsSection(
                  title: 'About',
                  children: [
                    _SettingsTile(
                      icon: Icons.help_outline,
                      title: AppStrings.helpAbout,
                      subtitle: 'PhishGuard v${AppStrings.version}',
                      onTap: () {},
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled),
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: AppStrings.privacyPolicy,
                      onTap: () {},
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: AppSizes.paddingMD),

                // Logout
                PGButton(
                  label: AppStrings.logout,
                  isOutlined: true,
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, size: 16, color: AppColors.danger),
                  color: AppColors.danger,
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textDisabled,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: children.asMap().entries.map((entry) {
                final isLast = entry.key == children.length - 1;
                return Column(
                  children: [
                    entry.value,
                    if (!isLast)
                      const Divider(height: 1, indent: 56),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 18),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: trailing,
    );
  }
}
