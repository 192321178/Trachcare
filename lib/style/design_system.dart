import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trachcare/style/responsive.dart';

/// TrachCare design system — "Clinical Calm".
class AppColors {
  const AppColors._();

  // Brand
  static const Color teal = Color(0xFF0E6B5E);
  static const Color tealDeep = Color(0xFF084741);
  static const Color tealLight = Color(0xFF2E9E8B);
  static const Color mint = Color(0xFFA7DBAF);
  static const Color mintSoft = Color(0xFFDFF3E6);

  // Neutrals
  static const Color surface = Color(0xFFFDFEFD);
  static const Color surfaceMuted = Color(0xFFF2F6F4);
  static const Color surfaceAlt = Color(0xFFE8F1ED);
  static const Color ink = Color(0xFF0F2A24);
  static const Color inkDark = Color(0xFF0F2A24);
  static const Color inkBody = Color(0xFF3B554E);
  static const Color inkMuted = Color(0xFF7A938C);
  static const Color outline = Color(0xFFD6E2DC);
  static const Color divider = Color(0xFFEAF1EE);
  static const Color tealSoft = Color(0xFFDFF3E6);

  // Accents
  static const Color amber = Color(0xFFF4A82B);
  static const Color amberSoft = Color(0xFFFFF3DC);
  static const Color coral = Color(0xFFE8735A);
  static const Color coralSoft = Color(0xFFFDE8E3);
  static const Color sky = Color(0xFF3B82C4);
  static const Color skySoft = Color(0xFFE3EFF9);
  static const Color violet = Color(0xFF7C5CD6);

  // Semantic
  static const Color success = Color(0xFF17A06B);
  static const Color successSoft = Color(0xFFDCF5EA);
  static const Color warning = Color(0xFFE09B25);
  static const Color danger = Color(0xFFD9455F);
  static const Color dangerSoft = Color(0xFFFBE4E8);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF0E6B5E), Color(0xFF2E9E8B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFFA7DBAF), Color(0xFFDFF3E6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFF4A82B), Color(0xFFFFD98A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scrimGradient = LinearGradient(
    colors: [Color(0xCC08312B), Color(0x3308312B)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
}

class AppRadius {
  const AppRadius._();

  static const BorderRadius card = BorderRadius.all(Radius.circular(20));
  static const BorderRadius sheet =
      BorderRadius.vertical(top: Radius.circular(28));
  static const BorderRadius field = BorderRadius.all(Radius.circular(14));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(999));
  static const BorderRadius button = BorderRadius.all(Radius.circular(14));
  static const BorderRadius thumb = BorderRadius.all(Radius.circular(16));
}

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F0F2A24),
      blurRadius: 18,
      offset: Offset(0, 6),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x0A0F2A24),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x1F0E6B5E),
      blurRadius: 22,
      offset: Offset(0, 10),
      spreadRadius: -6,
    ),
  ];

  static const List<BoxShadow> nav = [
    BoxShadow(
      color: Color(0x140F2A24),
      blurRadius: 26,
      offset: Offset(0, -6),
      spreadRadius: -8,
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x332E9E8B),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -6,
    ),
  ];
}

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double page = 20;
}

class AppType {
  const AppType._();

  static TextTheme textTheme() {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      displaySmall: base.displaySmall
          ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.ink),
      headlineMedium: base.headlineMedium
          ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.ink),
      headlineSmall: base.headlineSmall
          ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink),
      titleLarge: base.titleLarge
          ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink),
      titleMedium: base.titleMedium
          ?.copyWith(fontWeight: FontWeight.w600, color: AppColors.ink),
      titleSmall: base.titleSmall
          ?.copyWith(fontWeight: FontWeight.w600, color: AppColors.inkBody),
      bodyLarge: base.bodyLarge?.copyWith(color: AppColors.inkBody),
      bodyMedium: base.bodyMedium?.copyWith(color: AppColors.inkBody),
      bodySmall: base.bodySmall?.copyWith(color: AppColors.inkMuted),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      labelMedium: base.labelMedium
          ?.copyWith(fontWeight: FontWeight.w600, color: AppColors.inkMuted),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.inkMuted,
        letterSpacing: 0.8,
      ),
    );
  }

  /// Uppercase section eyebrow used above card groups.
  static TextStyle get eyebrow => GoogleFonts.plusJakartaSans(
        fontSize: AppSize.s(11),
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.teal,
      );
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final text = AppType.textTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surfaceMuted,
      colorScheme: const ColorScheme.light(
        primary: AppColors.teal,
        onPrimary: Colors.white,
        primaryContainer: AppColors.mintSoft,
        onPrimaryContainer: AppColors.tealDeep,
        secondary: AppColors.amber,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        onSurfaceVariant: AppColors.inkMuted,
        error: AppColors.danger,
        outline: AppColors.outline,
      ),
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 16),
        hintStyle: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
        labelStyle: text.bodyMedium?.copyWith(color: AppColors.inkBody),
        border: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: const BorderSide(color: AppColors.teal, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.field,
          borderSide: const BorderSide(color: AppColors.danger, width: 1.8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.teal,
          minimumSize: const Size(0, 52),
          side: const BorderSide(color: AppColors.teal, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.teal,
          textStyle: text.labelLarge,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.field),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        side: BorderSide.none,
        labelStyle: text.labelMedium,
        shape: const StadiumBorder(),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.teal,
        linearTrackColor: AppColors.surfaceAlt,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
