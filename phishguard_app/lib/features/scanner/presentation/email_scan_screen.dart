import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';
import 'package:phishguard_app/features/scanner/presentation/url_scan_screen.dart';

class EmailScanScreen extends ConsumerStatefulWidget {
  const EmailScanScreen({super.key});

  @override
  ConsumerState<EmailScanScreen> createState() => _EmailScanScreenState();
}

class _EmailScanScreenState extends ConsumerState<EmailScanScreen> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _scan() {
    if (_emailCtrl.text.trim().isEmpty) return;
    ref.read(scanStateProvider.notifier).scan(_emailCtrl.text, 'EMAIL');
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanStateProvider);

    ref.listen(scanStateProvider, (_, next) {
      if (next is ScanDone) {
        context.go('/scan/result', extra: next.result.toJson());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(scanStateProvider.notifier).reset();
        });
      }
      if (next is ScanFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: AppColors.danger),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(scanStateProvider.notifier).reset();
        });
      }
    });

    final isLoading = scanState is ScanLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.emailScanner)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PGCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.email_outlined, color: AppColors.accent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email Link Scanner', style: Theme.of(context).textTheme.titleLarge),
                          Text('Paste email content — all links will be extracted & scanned',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Email input
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _emailCtrl,
                      maxLines: 8,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Paste the full email content here (subject, body, sender)...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(AppSizes.paddingMD),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _emailCtrl.clear(),
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: PGButton(
                          label: isLoading ? 'Scanning Links...' : 'Scan Email',
                          isLoading: isLoading,
                          onPressed: _scan,
                          icon: const Icon(Icons.shield_outlined, color: Colors.black, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // Tips section
            Text('What We Detect', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...[
              ('🔗', 'All URLs extracted automatically from email body'),
              ('🎣', 'Phishing links disguised with trusted brand names'),
              ('🏦', 'Fake banking portals (SBI, HDFC, ICICI, etc.)'),
              ('🔄', 'Redirect chains hiding malicious destinations'),
              ('🔒', 'Insecure HTTP links in "secure" bank emails'),
              ('⚠️', 'Suspicious urgency keywords (verify now, blocked)'),
            ].map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(tip.$1, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(tip.$2, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
