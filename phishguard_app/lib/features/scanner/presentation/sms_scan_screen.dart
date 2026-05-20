import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';
import 'package:phishguard_app/features/scanner/presentation/url_scan_screen.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsScanScreen extends ConsumerStatefulWidget {
  const SmsScanScreen({super.key});

  @override
  ConsumerState<SmsScanScreen> createState() => _SmsScanScreenState();
}

class _SmsScanScreenState extends ConsumerState<SmsScanScreen> {
  final _manualCtrl = TextEditingController();
  final SmsQuery _query = SmsQuery();
  
  bool _showManual = false;
  bool _isLoadingSms = false;
  bool _permissionDenied = false;
  List<SmsMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoadingSms = true;
      _permissionDenied = false;
    });

    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 30, // Fetch the last 30 messages to avoid freezing
      );
      setState(() {
        _messages = messages;
        _isLoadingSms = false;
      });
    } else {
      var request = await Permission.sms.request();
      if (request.isGranted) {
        _loadMessages();
      } else {
        setState(() {
          _permissionDenied = true;
          _isLoadingSms = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _manualCtrl.dispose();
    super.dispose();
  }

  void _scanMessage(String? content) {
    if (content == null || content.isEmpty) return;
    ref.read(scanStateProvider.notifier).scan(content, 'SMS');
  }

  bool _looksSuspicious(String? body) {
    if (body == null) return false;
    final lower = body.toLowerCase();
    // Basic local keyword highlighting (does not replace the real backend scan)
    return lower.contains('kyc') ||
        lower.contains('block') ||
        lower.contains('freeze') ||
        lower.contains('urgent') ||
        lower.contains('refund') ||
        lower.contains('http');
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.smsScanner),
        actions: [
          IconButton(
            icon: Icon(
              _showManual ? Icons.message_outlined : Icons.edit_outlined,
              color: AppColors.primary,
            ),
            onPressed: () => setState(() => _showManual = !_showManual),
            tooltip: _showManual ? 'View SMS List' : 'Enter Manually',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            PGCard(
              color: AppColors.infoBg,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Scans SMS messages for phishing links, KYC scams, OTP fraud, and courier delivery scams.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: AppSizes.paddingMD),

            if (_showManual) ...[
              // Manual input
              Text('Paste SMS Content', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              PGCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _manualCtrl,
                      maxLines: 4,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Paste suspicious SMS content here...',
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PGButton(
                      label: 'Scan SMS',
                      isLoading: scanState is ScanLoading,
                      onPressed: () => _scanMessage(_manualCtrl.text),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // SMS message list
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Inbox Messages', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20, color: AppColors.textSecondary),
                    onPressed: _isLoadingSms ? null : _loadMessages,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isLoadingSms)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (_permissionDenied)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 40, color: AppColors.warning),
                        const SizedBox(height: 10),
                        const Text('SMS permission denied. We cannot read your inbox.', textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => openAppSettings(),
                          child: const Text('Open Settings'),
                        )
                      ],
                    ),
                  ),
                )
              else if (_messages.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No SMS messages found.'),
                  ),
                )
              else
                ..._messages.asMap().entries.map((entry) {
                  final message = entry.value;
                  final isSuspicious = _looksSuspicious(message.body);
                  return _SmsCard(
                    message: message,
                    isSuspicious: isSuspicious,
                    index: entry.key,
                    onScan: () => _scanMessage(message.body),
                    isLoading: scanState is ScanLoading,
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }
}

class _SmsCard extends StatelessWidget {
  final SmsMessage message;
  final bool isSuspicious;
  final int index;
  final VoidCallback onScan;
  final bool isLoading;

  const _SmsCard({
    required this.message,
    required this.isSuspicious,
    required this.index,
    required this.onScan,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSuspicious ? AppColors.danger : AppColors.border;
    final iconColor = isSuspicious ? AppColors.danger : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PGCard(
        color: isSuspicious
            ? AppColors.dangerBg.withOpacity(0.5)
            : AppColors.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.sms_outlined, size: 14, color: iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message.sender ?? 'Unknown',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSuspicious ? AppColors.danger : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSuspicious)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                    ),
                    child: const Text(
                      '⚠️ Suspicious Keyword',
                      style: TextStyle(color: AppColors.danger, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message.body ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : onScan,
                    icon: const Icon(Icons.security, size: 14),
                    label: const Text('Scan Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: (20 * index).clamp(0, 500))).fadeIn(duration: 300.ms).slideX(begin: 0.1);
  }
}
