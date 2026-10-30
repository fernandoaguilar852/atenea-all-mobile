import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  AppColors._();

  // Brand Colors - Azules Modernos (Inspirado en Slack, Notion, Linear)
  static const Color primary = Color(0xFF0066FF); // Azul eléctrico moderno
  static const Color primaryLight = Color(0xFF4D94FF); // Azul claro vibrante
  static const Color primaryDark = Color(0xFF0052CC); // Azul oscuro (hover/pressed)
  static const Color secondary = Color(0xFF00C2FF); // Azul cyan vibrante (accents)

  // Backgrounds - Grises modernos tipo Instagram
  static const Color background = Color(0xFFFAFAFA); // Casi blanco (más limpio)
  static const Color surface = Color(0xFFFFFFFF); // Blanco puro para cards
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Gris muy claro para alternancia
  static const Color cardBackground = Color(0xFFFFFFFF); // Alias de surface

  // Textos - Grises balanceados
  static const Color textPrimary = Color(0xFF1A1A1A); // Negro suave (no #000 puro)
  static const Color textSecondary = Color(0xFF666666); // Gris medio
  static const Color textMuted = Color(0xFF999999); // Gris claro

  // Bordes - Sutiles tipo flat design
  static const Color borderColor = Color(0xFFE5E5E5); // Gris muy claro
  static const Color borderMedium = Color(0xFFD4D4D4); // Gris claro (hover)
  static const Color borderStrong = Color(0xFFB3B3B3); // Gris visible (focus)

  // Semantic Colors - Actualizados (Tailwind-inspired)
  static const Color success = Color(0xFF10B981); // Verde moderno
  static const Color warning = Color(0xFFF59E0B); // Naranja (mejor que amarillo)
  static const Color danger = Color(0xFFEF4444); // Rojo moderno
  static const Color info = Color(0xFF3B82F6); // Azul info

  // Shades - Escala de grises refinada
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFE5E5E5);
  static const Color grey300 = Color(0xFFD4D4D4);
  static const Color grey400 = Color(0xFFA3A3A3);
  static const Color grey500 = Color(0xFF737373);
  static const Color grey600 = Color(0xFF525252);
  static const Color grey700 = Color(0xFF404040);
  static const Color grey800 = Color(0xFF262626);
  static const Color grey900 = Color(0xFF171717);

  // Gradients - Modernizados
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, primary],
  );
}

class AppTheme {
  AppTheme._();

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter', // ✅ Activado

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.danger,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimary,
      onError: AppColors.white,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.background,

    // AppBar - Flat style con border
    appBarTheme: const AppBarTheme(
      elevation: 0, // Sin sombra
      centerTitle: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        height: 1.2,
      ),
    ),

    // Card - Flat style (sin elevation)
    cardTheme: CardTheme(
      elevation: 0, // Sin sombra
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.borderColor, width: 1),
      ),
      color: AppColors.surface,
      margin: EdgeInsets.zero,
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 14,
        fontFamily: 'Inter',
      ),
      errorStyle: const TextStyle(
        color: AppColors.danger,
        fontSize: 12,
        fontFamily: 'Inter',
      ),
    ),

    // Elevated Button - Flat style
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0, // Sin sombra
        shadowColor: Colors.transparent,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          height: 1.2,
        ),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          height: 1.2,
        ),
      ),
    ),

    // Outlined Button - Border más visible
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          height: 1.2,
        ),
      ),
    ),

    // FloatingActionButton - Sombra muy sutil
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 2, // Sombra reducida
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
    ),

    // Bottom Navigation Bar - Flat con border
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0, // Sin sombra
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey400,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        height: 1.2,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
        height: 1.2,
      ),
      type: BottomNavigationBarType.fixed,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.borderColor,
      thickness: 1,
      space: 1,
    ),

    // Dialog - Sombra muy sutil
    dialogTheme: DialogTheme(
      elevation: 4, // Sombra reducida
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      titleTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        height: 1.2,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontFamily: 'Inter',
        height: 1.5,
      ),
    ),

    // Typography - Con Inter y line heights mejoradas
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
        height: 1.2,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        fontFamily: 'Inter',
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        fontFamily: 'Inter',
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        fontFamily: 'Inter',
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        fontFamily: 'Inter',
        height: 1.4,
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.grey100,
      selectedColor: AppColors.primary,
      labelStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
      secondaryLabelStyle: const TextStyle(
        color: AppColors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.grey800,
      contentTextStyle: const TextStyle(
        color: AppColors.white,
        fontSize: 14,
        fontFamily: 'Inter',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Dark Theme - Actualizado con misma filosofía
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter', // ✅ Activado

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondary,
      surface: AppColors.grey800,
      error: AppColors.danger,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
      onError: AppColors.white,
    ),

    scaffoldBackgroundColor: AppColors.grey900,
  );
}

// Spacing Constants (sin cambios)
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

// Border Radius Constants - Valores más pequeños (flat design)
class AppRadius {
  AppRadius._();

  static const double sm = 4; // Antes: 6
  static const double md = 8; // Antes: 10
  static const double lg = 12; // Antes: 14
  static const double xl = 16; // Antes: 20
  static const double full = 9999;
}

// Shadow Constants - Simplificados (solo para modals/dialogs)
class AppShadows {
  AppShadows._();

  // Sombra muy sutil para elevación mínima
  static List<BoxShadow> subtle = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.04),
      offset: const Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  // Sombra para modals y dialogs
  static List<BoxShadow> modal = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.08),
      offset: const Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  // Sombra para elementos flotantes (FABs)
  static List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.12),
      offset: const Offset(0, 8),
      blurRadius: 16,
    ),
  ];
}
