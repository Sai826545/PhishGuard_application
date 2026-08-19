import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/network/api_client.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';
import 'package:intl/intl.dart';

final communityReportsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/report/community');
  return response.data['data'] as List<dynamic>;
});

class ReportScamScreen extends ConsumerStatefulWidget {
  const ReportScamScreen({super.key});

  @override
  ConsumerState<ReportScamScreen> createState() => _ReportScamScreenState();
}

class _ReportScamScreenState extends ConsumerState<ReportScamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'BANK_SCAM';
  bool _isLoading = false;
  XFile? _screenshotFile;
  String _selectedCity = 'Delhi';

  final List<Map<String, dynamic>> _cities = const [
    {'name': 'Delhi', 'lat': 28.70, 'lng': 77.10},
    {'name': 'Mumbai', 'lat': 19.07, 'lng': 72.87},
    {'name': 'Jamtara', 'lat': 24.13, 'lng': 86.80},
    {'name': 'Bengaluru', 'lat': 12.97, 'lng': 77.59},
    {'name': 'Hyderabad', 'lat': 17.38, 'lng': 78.48},
    {'name': 'Chennai', 'lat': 13.08, 'lng': 80.27},
    {'name': 'Kolkata', 'lat': 22.57, 'lng': 88.36},
    {'name': 'Pune', 'lat': 18.52, 'lng': 73.85},
    {'name': 'Ahmedabad', 'lat': 23.02, 'lng': 72.57},
  ];

  final List<_Category> _categories = const [
    _Category('BANK_SCAM', '🏦 Bank Scam', Icons.account_balance_outlined),
    _Category('UPI_SCAM', '💸 UPI/Payment Scam', Icons.payment_outlined),
    _Category('COURIER_SCAM', '📦 Courier Fraud', Icons.local_shipping_outlined),
    _Category('GOVT_SCAM', '🏛️ Govt Portal Scam', Icons.account_balance),
    _Category('SMS_SCAM', '📱 SMS Phishing', Icons.sms_failed_outlined),
    _Category('EMAIL_SCAM', '📧 Email Phishing', Icons.email_outlined),
    _Category('OTHER', '⚠️ Other Scam', Icons.warning_amber_outlined),
  ];

  @override
  void dispose() {
    _contentCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _screenshotFile = file);
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      
      String? screenshotUrl;
      if (_screenshotFile != null) {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            _screenshotFile!.path,
            filename: _screenshotFile!.name,
          ),
        });
        final uploadResponse = await client.post('/report/upload', data: formData);
        screenshotUrl = uploadResponse.data['data']['url'];
      }

      final cityData = _cities.firstWhere((c) => c['name'] == _selectedCity);

      await client.post('/report', data: {
        'category': _selectedCategory,
        'content': _contentCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'screenshotUrl': screenshotUrl,
        'city': _selectedCity,
        'latitude': cityData['lat'],
        'longitude': cityData['lng'],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Report submitted! Thank you for protecting others.'),
            backgroundColor: AppColors.safe,
          ),
        );
        _contentCtrl.clear();
        _phoneCtrl.clear();
        _descCtrl.clear();
        setState(() {
          _screenshotFile = null;
          _selectedCity = 'Delhi';
        });
        // Refresh community feed provider after submitting a report
        ref.refresh(communityReportsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit. Please try again.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.reportScam),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Submit Report'),
              Tab(text: 'Community Feed'),
            ],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Submit Form
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info
                    PGCard(
                      color: AppColors.dangerBg,
                      child: Row(
                        children: [
                          const Icon(Icons.report_outlined, color: AppColors.danger, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Help the community by reporting scams. Your report may protect thousands of people.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.dangerLight,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: AppSizes.paddingLG),

                    // Category
                    Text(AppStrings.reportCategory, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat.key;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat.key),
                          child: AnimatedContainer(
                            duration: 200.ms,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.danger.withOpacity(0.15)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                              border: Border.all(
                                color: isSelected ? AppColors.danger : AppColors.border,
                                width: isSelected ? 1.5 : 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cat.icon, size: 14,
                                  color: isSelected ? AppColors.danger : AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  cat.label,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.danger : AppColors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ).animate().fadeIn(delay: 100.ms),

                    // City Dropdown Selector
                    const SizedBox(height: AppSizes.paddingLG),
                    Text('Scam Location (City)', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      dropdownColor: AppColors.card,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.map_outlined, color: AppColors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: _cities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city['name'] as String,
                          child: Text(city['name'] as String),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCity = val);
                        }
                      },
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: AppSizes.paddingLG),
                    // URL / Content
                    Text('Scam URL or Content (optional)', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    PGTextField(
                      controller: _contentCtrl,
                      hint: 'Paste the suspicious URL, phone number, or text',
                      maxLines: 2,
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: AppSizes.paddingMD),

                    // Phone number
                    Text('Scam Phone Number (optional)', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    PGTextField(
                      controller: _phoneCtrl,
                      hint: '+91 XXXXXXXXXX',
                      keyboardType: TextInputType.phone,
                      prefix: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: AppSizes.paddingMD),

                    // Description
                    Text('Describe the Scam *', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    PGTextField(
                      controller: _descCtrl,
                      hint: AppStrings.reportDescription,
                      maxLines: 4,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please describe the scam';
                        if (v.trim().length < 20) return 'Please provide more details (min 20 characters)';
                        return null;
                      },
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: AppSizes.paddingMD),

                    // Screenshot Attachment
                    Text('Attach Screenshot (optional)', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          border: Border.all(color: AppColors.border, width: 0.5),
                        ),
                        child: _screenshotFile == null
                            ? const Column(
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 36),
                                  SizedBox(height: 8),
                                  Text('Tap to select a screenshot', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                ],
                              )
                            : Row(
                                children: [
                                  const Icon(Icons.insert_drive_file_outlined, color: AppColors.primary, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _screenshotFile!.name,
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontFamily: 'monospace'),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.clear, color: AppColors.danger, size: 18),
                                    onPressed: () => setState(() => _screenshotFile = null),
                                  ),
                                ],
                              ),
                      ),
                    ).animate().fadeIn(delay: 450.ms),

                    const SizedBox(height: AppSizes.paddingXL),

                    // Submit
                    PGButton(
                      label: AppStrings.submitReport,
                      isLoading: _isLoading,
                      onPressed: _submitReport,
                      icon: const Icon(Icons.send_outlined, color: Colors.black, size: 18),
                    ).animate().fadeIn(delay: 500.ms),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Tab 2: Community Feed
            const _CommunityFeedTab(),
          ],
        ),
      ),
    );
  }
}

class _CommunityFeedTab extends ConsumerWidget {
  const _CommunityFeedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(communityReportsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(communityReportsProvider.future),
      child: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: PGEmptyState(
              title: 'Error loading feed',
              subtitle: 'Could not fetch community scam reports.',
              icon: Icons.wifi_off_outlined,
              onAction: () => ref.refresh(communityReportsProvider),
              actionLabel: 'Retry',
            ),
          ),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return const Center(
              child: PGEmptyState(
                title: 'Clean Feed',
                subtitle: 'No scams reported by the community yet.',
                icon: Icons.security_outlined,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            itemCount: reports.length,
            itemBuilder: (context, idx) {
              final report = reports[idx] as Map<String, dynamic>;
              return _CommunityReportCard(report: report);
            },
          );
        },
      ),
    );
  }
}

class _CommunityReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  
  const _CommunityReportCard({required this.report});

  String _getCategoryLabel(String key) {
    switch (key) {
      case 'BANK_SCAM': return '🏦 Bank Scam';
      case 'UPI_SCAM': return '💸 UPI/Payment Scam';
      case 'COURIER_SCAM': return '📦 Courier Fraud';
      case 'GOVT_SCAM': return '🏛️ Govt Portal Scam';
      case 'SMS_SCAM': return '📱 SMS Phishing';
      case 'EMAIL_SCAM': return '📧 Email Phishing';
      default: return '⚠️ Other Scam';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = report['reportedAt'] != null 
        ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(report['reportedAt']))
        : 'Unknown Date';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PGCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '👤 By: ${report['reportedBy'] ?? 'Anonymous'}',
                        style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '📍 ${report['city'] ?? 'Unknown'}',
                        style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(color: AppColors.textDisabled, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getCategoryLabel(report['category'] ?? 'OTHER'),
              style: const TextStyle(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              report['description'] ?? '',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4),
            ),
            if (report['content'] != null && report['content'] != 'N/A') ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: SelectableText.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Payload/URL: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: report['content'],
                        style: const TextStyle(color: AppColors.accent, fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (report['screenshotUrl'] != null && (report['screenshotUrl'] as String).isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  AppStrings.baseUrl.replaceAll('/api', '') + report['screenshotUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Category {
  final String key;
  final String label;
  final IconData icon;

  const _Category(this.key, this.label, this.icon);
}
