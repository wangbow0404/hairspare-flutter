import 'package:flutter/material.dart';

/// Next.js 웹 앱의 디자인 시스템을 Flutter에 적용한 테마
class AppTheme {
  // 색상 팔레트 (Next.js Tailwind CSS 기반)
  static const Color primaryBlue = Color(0xFF3B82F6); // blue-500
  static const Color primaryBlueDark = Color(0xFF2563EB); // blue-600
  static const Color primaryPurple500 = Color(0xFFA855F7); // purple-500
  static const Color primaryPurple = Color(0xFF9333EA); // purple-600
  static const Color primaryPurpleDark = Color(0xFF7E22CE); // purple-700
  static const Color primaryPurpleDarker = Color(0xFF6B21A8); // purple-800
  static const Color primaryGreen = Color(0xFF10B981); // green-500
  static const Color primaryPink = Color(0xFFEC4899); // pink-500
  static const Color primaryPinkLight = Color(0xFFFDF2F8); // pink-50
  static const Color primaryPinkDarker = Color(0xFF9F1239); // pink-900
  static const Color primaryPurpleLight = Color(0xFFF3E8FF); // purple-50
  
  // 배경색
  static const Color backgroundGray = Color(0xFFF9FAFB); // gray-50
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGradientStart = Color(0xFFEFF6FF); // blue-50
  static const Color backgroundGradientMiddle = Color(0xFFF3E8FF); // purple-50
  static const Color backgroundGradientEnd = Color(0xFFFDF2F8); // pink-50
  
  // 텍스트 색상
  static const Color textPrimary = Color(0xFF111827); // gray-900
  static const Color textSecondary = Color(0xFF6B7280); // gray-600
  static const Color textTertiary = Color(0xFF9CA3AF); // gray-400
  static const Color textGray700 = Color(0xFF374151); // gray-700
  
  // 급구 관련 색상
  static const Color urgentRed = Color(0xFFEF4444); // red-500
  static const Color urgentRedLight = Color(0xFFFEE2E2); // red-100
  static const Color red50 = Color(0xFFFEF2F2); // red-50
  static const Color red200 = Color(0xFFFECACA); // red-200
  static const Color red600 = Color(0xFFDC2626); // red-600
  
  // 오렌지 색상 (일반 급구용)
  static const Color orange100 = Color(0xFFFFEDD5); // orange-100
  static const Color orange400 = Color(0xFFFB923C); // orange-400
  static const Color orange500 = Color(0xFFF97316); // orange-500
  static const Color orange50 = Color(0xFFFFF7ED); // orange-50
  static const Color orange600 = Color(0xFFEA580C); // orange-600
  
  // 그린 색상 (태그용)
  static const Color green50 = Color(0xFFF0FDF4); // green-50
  static const Color green100 = Color(0xFFD1FAE5); // green-100
  static const Color green600 = Color(0xFF16A34A); // green-600
  static const Color green700 = Color(0xFF047857); // green-700
  
  // 퍼플 색상 (태그용)
  static const Color purple100 = Color(0xFFF3E8FF); // purple-100
  static const Color purple700 = Color(0xFF7E22CE); // purple-700
  
  // 그라데이션 색상 (이미지 영역용)
  static const Color green200 = Color(0xFFBBF7D0); // green-200
  static const Color blue100 = Color(0xFFDBEAFE); // blue-100
  static const Color blue200 = Color(0xFFBFDBFE); // blue-200
  
  // 노란색 (카카오 로그인용 및 에너지용)
  static const Color yellow50 = Color(0xFFFEFCE8); // yellow-50
  static const Color yellow200 = Color(0xFFFEF9C3); // yellow-200
  static const Color yellow400 = Color(0xFFFACC15); // yellow-400
  static const Color yellow500 = Color(0xFFEAB308); // yellow-500
  static const Color yellow600 = Color(0xFFCA8A04); // yellow-600
  static const Color yellow800 = Color(0xFF854D0E); // yellow-800
  static const Color yellow900 = Color(0xFF713F12); // yellow-900
  
  // 테두리 색상
  static const Color borderGray = Color(0xFFE5E7EB); // gray-200
  static const Color borderGray300 = Color(0xFFD1D5DB); // gray-300
  
  // 간격 시스템 (8px 단위, Tailwind의 4px 단위 × 2)
  static const double spacing1 = 4.0;   // 0.5 (Tailwind)
  static const double spacing2 = 8.0;   // 1 (Tailwind)
  static const double spacing3 = 12.0;  // 1.5 (Tailwind)
  static const double spacing4 = 16.0;   // 2 (Tailwind)
  static const double spacing5 = 20.0;   // 2.5 (Tailwind)
  static const double spacing6 = 24.0;   // 3 (Tailwind)
  static const double spacing8 = 32.0;   // 4 (Tailwind)
  static const double spacing10 = 40.0;   // 5 (Tailwind)
  static const double spacing12 = 48.0;  // 6 (Tailwind)
  
  // 둥근 모서리 시스템
  static const double radiusSm = 4.0;   // rounded-sm
  static const double radiusMd = 8.0;    // rounded-md
  static const double radiusLg = 12.0;   // rounded-lg
  static const double radiusXl = 16.0;   // rounded-xl
  static const double radius2xl = 24.0;  // rounded-2xl
  static const double radius3xl = 28.0;  // rounded-3xl (관리자 카드용)
  static const double radiusFull = 9999.0; // rounded-full

  // 관리자 페이지용 스타일 (Refine 디자인 참고)
  static const Color adminPurple50 = Color(0xFFF5F3FF);
  static const Color adminPurple100 = Color(0xFFEDE9FE);
  static const Color adminPurple200 = Color(0xFFDDD6FE);
  static const Color adminPink50 = Color(0xFFFDF2F8);
  static const Color adminBlue50 = Color(0xFFEFF6FF);

  /// 관리자 배경 그라데이션 (purple-50 → blue-50 → pink-50)
  static BoxDecoration get adminBackgroundGradient => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [adminPurple50, adminBlue50, adminPink50],
        ),
      );

  /// 관리자 카드 스타일 (rounded-3xl, border-2 purple-100, shadow-lg)
  static BoxDecoration get adminCardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius3xl),
        border: Border.all(color: adminPurple100, width: 2),
        boxShadow: shadowLg,
      );

  /// 관리자 테이블 헤더 그라데이션
  static BoxDecoration get adminTableHeaderDecoration => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [adminPurple50, adminPink50],
        ),
      );
  
  // 그림자 시스템
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 1,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> shadowHover(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Material 테마 생성
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: primaryPurple,
        surface: backgroundWhite,
        background: backgroundGray,
        error: urgentRed,
      ),
      scaffoldBackgroundColor: backgroundGray,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundWhite,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 64, // text-6xl (모바일: 48px, 데스크탑: 64px)
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -1.0, // tracking-tight
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 48, // text-5xl
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.1,
        ),
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24, // text-2xl
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20, // text-xl
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20, // text-xl
          fontWeight: FontWeight.w600, // font-semibold
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18, // text-lg
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, // text-base
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, // text-sm
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12, // text-xs
          color: textSecondary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: backgroundWhite,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
  
  // 그라데이션 배경 (역할 선택 화면용)
  static BoxDecoration get gradientBackground {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          backgroundGradientStart,
          backgroundGradientMiddle,
          backgroundGradientEnd,
        ],
      ),
    );
  }
  
  // 급구 배지 스타일
  static BoxDecoration get urgentBadgeDecoration {
    return BoxDecoration(
      color: urgentRedLight,
      borderRadius: BorderRadius.circular(4),
    );
  }
  
  // 프리미엄 배지 스타일
  static BoxDecoration get premiumBadgeDecoration {
    return BoxDecoration(
      color: Colors.amber.shade50,
      borderRadius: BorderRadius.circular(radiusSm),
      border: Border.all(color: Colors.amber.shade300),
    );
  }
  
  // 간격 헬퍼 메서드
  static EdgeInsets spacing(double value) => EdgeInsets.all(value);
  static EdgeInsets spacingHorizontal(double value) => EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets spacingVertical(double value) => EdgeInsets.symmetric(vertical: value);
  static EdgeInsets spacingSymmetric({required double horizontal, required double vertical}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  
  // 둥근 모서리 헬퍼 메서드
  static BorderRadius borderRadius(double radius) => BorderRadius.circular(radius);
  
  // 그림자 헬퍼 메서드
  static List<BoxShadow> getShadow(String size) {
    switch (size) {
      case 'sm':
        return shadowSm;
      case 'md':
        return shadowMd;
      case 'lg':
        return shadowLg;
      case 'xl':
        return shadowXl;
      default:
        return shadowMd;
    }
  }
  
  // InputDecoration 기본 스타일
  static InputDecoration get inputDecoration {
    return InputDecoration(
      filled: true,
      fillColor: backgroundWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: borderGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: borderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: urgentRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: urgentRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
