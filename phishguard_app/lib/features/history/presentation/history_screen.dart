import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/network/api_client.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';
import 'package:phishguard_app/features/auth/domain/models.dart';
import 'package:intl/intl.dart';

final historyProvider = FutureProvider.family<List<ScanResultModel>, String>((ref, filter) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/history', queryParameters: {
    'page': 0,
    'size': 50,
    'filter': filter,
  });
  final items = (response.data['data']['content'] as List<dynamic>);
  return items.map((e) => ScanResultModel.fromJson(e as Map<String, dynamic>)).toList();
});

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _filter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider(_filter));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.history),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh history',
            onPressed: () => ref.refresh(historyProvider(_filter)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            color: AppColors.card,
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'ALL', child: Text('All')),
              const PopupMenuItem(value: 'SAFE', child: Text('Safe')),
              const PopupMenuItem(value: 'SUSPICIOUS', child: Text('Suspicious')),
              const PopupMenuItem(value: 'DANGEROUS', child: Text('Dangerous')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMD,
              vertical: AppSizes.paddingSM,
            ),
            child: Row(
              children: ['ALL', 'SAFE', 'SUSPICIOUS', 'DANGEROUS'].map((f) {
                final isSelected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.card,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
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

          // History list
          Expanded(
            child: historyAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              error: (err, _) => PGEmptyState(
                title: 'Failed to Load',
                subtitle: 'Could not fetch scan history.',
                icon: Icons.history_outlined,
                onAction: () => ref.refresh(historyProvider(_filter)),
                actionLabel: 'Retry',
              ),
              data: (items) => items.isEmpty
                  ? const PGEmptyState(
                      title: 'No History',
                      subtitle: 'Start scanning URLs, QR codes, or SMS messages to build your history.',
                      icon: Icons.history_outlined,
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => ref.refresh(historyProvider(_filter)),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: items.length,
                        itemBuilder: (context, i) => _HistoryItem(
                          item: items[i],
                          index: i,
                          onDelete: () async {
                            if (items[i].historyId != null) {
                              final client = ref.read(apiClientProvider);
                              await client.delete('/history/${items[i].historyId}');
                              ref.refresh(historyProvider(_filter));
                            }
                          },
                          onTap: () {
                            context.go('/scan/result', extra: items[i].toJson());
                          },
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final ScanResultModel item;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _HistoryItem({
    required this.item,
    required this.index,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.statusColor(item.resultStatus);
    final typeIcon = _scanTypeIcon(item.scanType);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: PGCard(
          child: Row(
            children: [
              // Type icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(typeIcon, color: statusColor, size: 20),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.scannedContent.length > 40
                                ? '${item.scannedContent.substring(0, 40)}...'
                                : item.scannedContent,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge(status: item.resultStatus),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          item.scanType,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textDisabled,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('•', style: const TextStyle(color: AppColors.textDisabled)),
                        const SizedBox(width: 8),
                        Text(
                          item.scannedAt != null
                              ? DateFormat('dd MMM, hh:mm a').format(item.scannedAt!)
                              : 'Unknown time',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textDisabled),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 40 * index)).fadeIn(duration: 250.ms).slideX(begin: 0.1);
  }

  IconData _scanTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'QR': return Icons.qr_code_scanner;
      case 'SMS': return Icons.sms_outlined;
      case 'EMAIL': return Icons.email_outlined;
      default: return Icons.link;
    }
  }
}
