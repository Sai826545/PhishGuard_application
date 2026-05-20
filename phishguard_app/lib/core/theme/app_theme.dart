import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phishguard_app/core/constants/app_colors.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),

      // === App Bar ===
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: AppSizes.textXL,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // === Text Theme ===
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: GoogleFonts.inter(
            fontSize: AppSizes.textHero,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: AppSizes.textDisplay,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          headlineLarge: GoogleFonts.inter(
            fontSize: AppSizes.textXXL,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: AppSizes.textXL,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: AppSizes.textLG,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: AppSizes.textMD,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: AppSizes.textLG,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: AppSizes.textMD,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: AppSizes.textSM,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: AppSizes.textMD,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),

      // === Elevated Button ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: AppSizes.textMD,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),

      // === Outlined Button ===
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: AppSizes.textMD,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // === Input Decoration ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMD,
          vertical: AppSizes.paddingMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textHint,
          fontSize: AppSizes.textMD,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: AppSizes.textMD,
        ),
      ),

      // === Card ===
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: AppSizes.paddingSM),
      ),

      // === Divider ===
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
        space: 1,
      ),

      // === Bottom Navigation ===
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: AppSizes.textXS,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: AppSizes.textXS,
        ),
      ),

      // === Snack Bar ===
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardElevated,
        contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // === Switch ===
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryDark;
          return AppColors.border;
        }),
      ),

      // === Chip ===
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: GoogleFonts.inter(
          fontSize: AppSizes.textSM,
          color: AppColors.textPrimary,
        ),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSM,
          vertical: AppSizes.paddingXS,
        ),
      ),
    );
  }
}
