import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';

/// Primary CTA button with gradient background
class PGButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;
  final Color? color;
  final double? width;

  const PGButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: AppSizes.buttonHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(),
        ),
      );
    }

    return Container(
      width: width ?? double.infinity,
      height: AppSizes.buttonHeight,
      decoration: BoxDecoration(
        gradient: onPressed == null || isLoading ? null : AppColors.primaryGradient,
        color: onPressed == null || isLoading ? AppColors.border : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [icon!, const SizedBox(width: 8), Text(label)],
      );
    }
    return Text(label);
  }
}

/// Glassmorphism-style card
class PGCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;

  const PGCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSizes.paddingMD),
        decoration: BoxDecoration(
          color: color ?? AppColors.card,
          borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.radiusLG),
          border: Border.all(color: AppColors.border, width: 0.5),
          boxShadow: boxShadow,
        ),
        child: child,
      ),
    );
  }
}

/// Styled text input
class PGTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final Widget? prefix;
  final int maxLines;
  final VoidCallback? onTap;
  final bool readOnly;
  final void Function(String)? onChanged;

  const PGTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffix,
    this.prefix,
    this.maxLines = 1,
    this.onTap,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      onTap: onTap,
      readOnly: readOnly,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffix,
        prefixIcon: prefix,
      ),
    );
  }
}

/// Status badge (Safe / Suspicious / Dangerous)
class StatusBadge extends StatelessWidget {
  final String status;
  final bool large;

  const StatusBadge({super.key, required this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    final bgColor = AppColors.statusBgColor(status);
    final icon = _getIcon(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? AppSizes.paddingMD : AppSizes.paddingSM,
        vertical: large ? AppSizes.paddingSM : AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: large ? 20 : 14),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: large ? AppSizes.textMD : AppSizes.textSM,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String status) {
    switch (status.toUpperCase()) {
      case 'SAFE': return Icons.check_circle_outline;
      case 'SUSPICIOUS': return Icons.warning_amber_outlined;
      case 'DANGEROUS': return Icons.dangerous_outlined;
      default: return Icons.help_outline;
    }
  }
}

/// Risk score circular meter
class RiskMeter extends StatelessWidget {
  final int score;
  final double size;

  const RiskMeter({super.key, required this.score, this.size = 120});

  @override
  Widget build(BuildContext context) {
    final status = score <= 30 ? 'SAFE' : score <= 60 ? 'SUSPICIOUS' : 'DANGEROUS';
    final color = AppColors.statusColor(status);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  color: color,
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Risk',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: size * 0.12,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(
      begin: const Offset(0.5, 0.5),
      duration: 600.ms,
      curve: Curves.elasticOut,
    );
  }
}

/// Loading shimmer placeholder
class PGLoadingCard extends StatelessWidget {
  final double height;
  final double? width;

  const PGLoadingCard({super.key, this.height = 80, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
    ).animate(onPlay: (c) => c.repeat())
      .shimmer(duration: 1500.ms, color: AppColors.cardElevated);
  }
}

/// Empty state widget
class PGEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const PGEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, size: 48, color: AppColors.textDisabled),
            ),
            const SizedBox(height: AppSizes.paddingLG),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingSM),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: AppSizes.paddingXL),
              PGButton(label: actionLabel ?? 'Action', onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

/// Severity chip
class SeverityChip extends StatelessWidget {
  final String severity;

  const SeverityChip({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.severityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: AppSizes.textXS,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
