import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/network/api_client.dart';
import 'package:phishguard_app/core/widgets/pg_widgets.dart';

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

      await client.post('/report', data: {
        'category': _selectedCategory,
        'content': _contentCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'screenshotUrl': screenshotUrl,
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
        setState(() => _screenshotFile = null);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.reportScam)),
      body: SingleChildScrollView(
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
    );
  }
}

class _Category {
  final String key;
  final String label;
  final IconData icon;

  const _Category(this.key, this.label, this.icon);
}
