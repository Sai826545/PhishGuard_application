import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === Base ===
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color card = Color(0xFF1C2333);
  static const Color cardElevated = Color(0xFF243044);
  static const Color border = Color(0xFF2A3550);

  // === Brand ===
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryDark = Color(0xFF00A884);
  static const Color primaryLight = Color(0xFF33DDB8);
  static const Color accent = Color(0xFF7B61FF);

  // === Status ===
  static const Color safe = Color(0xFF00C896);
  static const Color safeLight = Color(0xFF1AE0A8);
  static const Color safeBg = Color(0xFF0A2E24);

  static const Color warning = Color(0xFFFFB800);
  static const Color warningLight = Color(0xFFFFD04D);
  static const Color warningBg = Color(0xFF2E2400);

  static const Color danger = Color(0xFFFF4C4C);
  static const Color dangerLight = Color(0xFFFF7070);
  static const Color dangerBg = Color(0xFF2E0A0A);

  static const Color info = Color(0xFF4C9AFF);
  static const Color infoBg = Color(0xFF0A1E2E);

  // === Text ===
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color textDisabled = Color(0xFF4A5568);
  static const Color textHint = Color(0xFF6B7280);

  // === Gradients ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0E1A), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF4C4C), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient safeGradient = LinearGradient(
    colors: [Color(0xFF00C896), Color(0xFF00D4AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === Severity ===
  static Color severityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return danger;
      case 'HIGH':
        return Color(0xFFFF7043);
      case 'MEDIUM':
        return warning;
      case 'LOW':
        return info;
      default:
        return textSecondary;
    }
  }

  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SAFE':
        return safe;
      case 'SUSPICIOUS':
        return warning;
      case 'DANGEROUS':
        return danger;
      default:
        return textSecondary;
    }
  }

  static Color statusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'SAFE':
        return safeBg;
      case 'SUSPICIOUS':
        return warningBg;
      case 'DANGEROUS':
        return dangerBg;
      default:
        return card;
    }
  }
}
