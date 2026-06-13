import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 한국 법정 공휴일·대체공휴일 (2025–2027, 행정안전부 고시 기준).
class KoreanPublicHolidays {
  KoreanPublicHolidays._();

  static final Set<String> _dates = {
    // 2025
    '2025-01-01',
    '2025-01-28', '2025-01-29', '2025-01-30', // 설날
    '2025-03-01', '2025-03-03', // 삼일절·대체
    '2025-05-05',
    '2025-06-06', '2025-08-15', '2025-10-03',
    '2025-10-05', '2025-10-06', '2025-10-07', '2025-10-08', // 추석
    '2025-10-09', '2025-12-25',
    // 2026
    '2026-01-01',
    '2026-02-16', '2026-02-17', '2026-02-18', // 설날
    '2026-03-01', '2026-03-02',
    '2026-05-05', '2026-06-06', '2026-08-15', '2026-10-03',
    '2026-09-24', '2026-09-25', '2026-09-26', // 추석
    '2026-10-09', '2026-12-25',
    // 2027
    '2027-01-01',
    '2027-02-10', '2027-02-11', '2027-02-12', // 설날
    '2027-03-01', '2027-05-05', '2027-06-06', '2027-08-15',
    '2027-10-03', '2027-10-11', '2027-10-12', '2027-10-13', // 추석
    '2027-10-09', '2027-12-25',
  };

  static String dateKey(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  static bool isHoliday(DateTime day) => _dates.contains(dateKey(day));

  static bool isSunday(DateTime day) => day.weekday == DateTime.sunday;

  static bool isSaturday(DateTime day) => day.weekday == DateTime.saturday;

  /// 일요일·공휴일 빨강, 토요일 파랑.
  static Color dayTextColor(
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
    double outsideAlpha = 1.0,
  }) {
    if (isSelected) return Colors.white;
    if (isToday && !isSelected) return AppTheme.primaryBlue;
    if (isHoliday(day) || isSunday(day)) {
      return AppTheme.urgentRed.withValues(alpha: outsideAlpha);
    }
    if (isSaturday(day)) {
      return AppTheme.primaryBlue.withValues(alpha: outsideAlpha);
    }
    return AppTheme.textPrimary.withValues(alpha: outsideAlpha);
  }

  static Color dowHeaderColor(DateTime day) {
    if (isSunday(day)) return AppTheme.urgentRed;
    if (isSaturday(day)) return AppTheme.primaryBlue;
    return AppTheme.textSecondary;
  }

  static const List<String> dowLabelsKo = ['일', '월', '화', '수', '목', '금', '토'];
}
