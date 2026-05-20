import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/network/api_client.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';
import 'package:phishguard_app/features/auth/domain/models.dart';

// Scan state
sealed class ScanState {}
class ScanIdle extends ScanState {}
class ScanLoading extends ScanState {}
class ScanDone extends ScanState {
  final ScanResultModel result;
  ScanDone(this.result);
}
class ScanFailed extends ScanState {
  final String message;
  ScanFailed(this.message);
}

final scanStateProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(ref.read(apiClientProvider));
});

class ScanNotifier extends StateNotifier<ScanState> {
  final ApiClient _client;

  ScanNotifier(this._client) : super(ScanIdle());

  Future<void> scan(String content, String type) async {
    if (content.trim().isEmpty) return;
    state = ScanLoading();
    try {
      final endpoint = switch (type) {
        'QR' => '/scan/qr',
        'SMS' => '/scan/sms',
        'EMAIL' => '/scan/email',
        _ => '/scan/url',
      };
      final response = await _client.post(endpoint, data: {'content': content});
      final result = ScanResultModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
      state = ScanDone(result);
    } catch (e) {
      state = ScanFailed(_parseError(e));
    }
  }

  void reset() => state = ScanIdle();

  String _parseError(dynamic e) {
    if (e.toString().contains('401')) return 'Session expired. Please login again.';
    if (e.toString().contains('SocketException')) return AppStrings.networkError;
    return AppStrings.serverError;
  }
}

class UrlScanScreen extends ConsumerStatefulWidget {
  const UrlScanScreen({super.key});

  @override
  ConsumerState<UrlScanScreen> createState() => _UrlScanScreenState();
}

class _UrlScanScreenState extends ConsumerState<UrlScanScreen> {
  final _urlCtrl = TextEditingController();
  final List<String> _recentLinks = [];

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlCtrl.text = data!.text!;
    }
  }

  void _scan() {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;
    if (!_recentLinks.contains(url)) {
      setState(() => _recentLinks.insert(0, url));
    }
    ref.read(scanStateProvider.notifier).scan(url, 'URL');
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanStateProvider);

    ref.listen(scanStateProvider, (_, next) {
      if (next is ScanDone) {
        context.go('/scan/result', extra: next.result.toJson());
        ref.read(scanStateProvider.notifier).reset();
      }
      if (next is ScanFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: AppColors.danger),
        );
        ref.read(scanStateProvider.notifier).reset();
      }
    });

    final isLoading = scanState is ScanLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.urlScanner),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
            onPressed: () => context.go('/scan/qr'),
            tooltip: 'Switch to QR Scanner',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            PGCard(
              color: AppColors.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.link, color: AppColors.danger, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('URL Scanner',
                              style: Theme.of(context).textTheme.titleLarge),
                          Text('Paste any suspicious link to analyze it',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.paddingMD),

                  // URL input
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _urlCtrl,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: AppStrings.pasteLink,
                        hintStyle: const TextStyle(color: AppColors.textHint),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(AppSizes.paddingMD),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingMD),

                  // Action buttons row
                  Row(
                    children: [
                      // Paste button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pasteFromClipboard,
                          icon: const Icon(Icons.content_paste, size: 16),
                          label: const Text(AppStrings.pasteButton),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Clear button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _urlCtrl.clear(),
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text(AppStrings.clearText),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Scan button
                  PGButton(
                    label: isLoading ? 'Analyzing...' : AppStrings.scanNow,
                    isLoading: isLoading,
                    onPressed: _scan,
                    icon: const Icon(Icons.security, color: Colors.black, size: 18),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

            const SizedBox(height: 24),

            // Other scan types
            Text('Other Scan Types', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                _ScanTypeChip(
                  label: 'QR Code',
                  icon: Icons.qr_code_scanner,
                  onTap: () => context.go('/scan/qr'),
                ),
                const SizedBox(width: 10),
                _ScanTypeChip(
                  label: 'SMS',
                  icon: Icons.sms_outlined,
                  onTap: () => context.go('/scan/sms'),
                ),
                const SizedBox(width: 10),
                _ScanTypeChip(
                  label: 'Email',
                  icon: Icons.email_outlined,
                  onTap: () => context.go('/scan/email'),
                ),
              ],
            ),

            if (_recentLinks.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(AppStrings.recentLinks, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ..._recentLinks.take(5).map((url) => _RecentLinkItem(
                url: url,
                onTap: () {
                  _urlCtrl.text = url;
                  _scan();
                },
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScanTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ScanTypeChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            )),
          ],
        ),
      ),
    );
  }
}

class _RecentLinkItem extends StatelessWidget {
  final String url;
  final VoidCallback onTap;

  const _RecentLinkItem({required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.history, size: 16, color: AppColors.textDisabled),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                url,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.north_west, size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
