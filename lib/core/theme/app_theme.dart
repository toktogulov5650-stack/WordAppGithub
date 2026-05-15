import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFFFFFF);
  static const backgroundElevated = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const cardSecondary = Color(0xFFF7F7F8);
  static const overlay = Color(0xF7FFFFFF);

  static const textDark = Color(0xFF1D1D1F);
  static const textMuted = Color(0xFF6E6E73);
  static const textTertiary = Color(0xFF8E8E93);

  static const primary = Color(0xFF1D1D1F);
  static const primaryDark = Color(0xFF000000);

  static const actionBlue = Color(0xFF007AFF);
  static const actionBlueDark = Color(0xFF005BBB);

  static const success = Color(0xFF22C55E);
  static const successDark = Color(0xFF166534);
  static const successSurface = Color(0xFFDCFCE7);

  static const warning = Color(0xFFF59E0B);
  static const warningDark = Color(0xFF9A5D00);
  static const warningSurface = Color(0xFFFEF3C7);

  static const error = Color(0xFFEF4444);
  static const errorDark = Color(0xFF991B1B);
  static const errorSurface = Color(0xFFFEE2E2);

  static const border = Color(0xFFE5E5EA);
  static const divider = Color(0xFFEDEDF0);

  static const lime = Color(0xFFE8E8ED);
  static const softBlue = Color(0xFFEAF2FF);
  static const softGreen = successSurface;
  static const verySoftGreen = Color(0xFFF1FFF6);
  static const softLime = Color(0xFFF2F2F7);
  static const softYellow = warningSurface;
  static const softWarning = warningSurface;
  static const softRed = errorSurface;
  static const surfaceGreen = Color(0xFFF1FFF6);

  static const shadowBlue = Color(0x12000000);
  static const shadowGreen = Color(0x10000000);
  static const shadowSoft = Color(0x0D000000);
  static const shadowStrong = Color(0x14000000);

  static const brandGreen = success;
  static const brandGreenDark = successDark;
  static const secondaryPurple = Color(0xFF6366F1);
  static const pastelBlue = softBlue;
  static const pastelPurple = Color(0xFFEDE9FE);
}

class AppTheme {
  static ThemeData get lightTheme {
    const textTheme = TextTheme(
      displaySmall: TextStyle(
        fontSize: 36,
        height: 1.08,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
        letterSpacing: -1,
      ),
      headlineMedium: TextStyle(
        fontSize: 29,
        height: 1.08,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
        letterSpacing: -0.6,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        height: 1.16,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        letterSpacing: -0.25,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        height: 1.35,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.15,
      ),
    );

    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.textDark,
      onSecondary: Colors.white,
      surface: AppColors.card,
      onSurface: AppColors.textDark,
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.divider,
      splashColor: AppColors.primary.withValues(alpha: 0.05),
      highlightColor: Colors.transparent,
      textTheme: textTheme,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x221D1D1F),
        selectionHandleColor: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          height: 1.2,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
          letterSpacing: -0.25,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textDark,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: isSelected ? AppColors.textDark : AppColors.textTertiary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            height: 1.15,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.textDark : AppColors.textTertiary,
          );
        }),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textDark,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.cardSecondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: AppColors.textTertiary,
        suffixIconColor: AppColors.textTertiary,
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.textDark, width: 1.25),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1.25),
        ),
      ),
    );
  }
}
