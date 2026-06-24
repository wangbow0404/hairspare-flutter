import 'package:flutter/material.dart';

/// Stitch admin panel design tokens (HTML mockup parity).
abstract final class AdminStitchTheme {
  static const Color primary = Color(0xFF580099);
  static const Color primaryContainer = Color(0xFF7800CE);
  static const Color secondary = Color(0xFF831ADA);
  static const Color secondaryContainer = Color(0xFF9E41F5);
  static const Color bgSubtle = Color(0xFFF9FAFB);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color borderDefault = Color(0xFFE5E7EB);
  static const Color textSecondary = Color(0xFF4E5968);
  static const Color onSurface = Color(0xFF161C25);
  static const Color statusError = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color surfaceContainerHigh = Color(0xFFE3E8F5);
  static const Color surfaceContainer = Color(0xFFE9EEFB);
  static const Color surfaceDim = Color(0xFFD5DAE7);
  static const Color primaryFixed = Color(0xFFF0DBFF);
  static const Color surfaceVariant = Color(0xFFDDE3EF);
  static const Color onSurfaceVariant = Color(0xFF4D4354);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFFFFFBFF);
  static const Color emerald = Color(0xFF10B981);

  static const double pageMargin = 20;
  static const double componentPadding = 16;
  static const double sectionGap = 16;
  static const double buttonHeight = 52;
  static const double stackTight = 8;
  static const double radiusXl = 12;
  static const double radiusLg = 8;
  static const double radius2xl = 16;

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surfaceCard,
        borderRadius: BorderRadius.circular(radiusXl),
        border: Border.all(color: borderDefault),
      );

  static BoxDecoration get searchFieldDecoration => BoxDecoration(
        color: surfaceCard,
        borderRadius: BorderRadius.circular(radiusXl),
        border: Border.all(color: borderDefault),
      );

  static const TextStyle headlineMobile = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: onSurface,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: onSurface,
  );

  static const TextStyle labelSm = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.01,
  );

  static const TextStyle bodyMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: onSurface,
  );

  static const TextStyle bodyLg = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: onSurface,
  );

  static const LinearGradient paymentsGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, secondary],
  );
}
