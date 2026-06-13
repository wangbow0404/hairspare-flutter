import 'package:flutter/material.dart';

/// 스케줄 상태 태그용 저채도 파스텔 팔레트.
abstract final class ScheduleStatusChipTheme {
  ScheduleStatusChipTheme._();

  static (Color bg, Color fg, Color? border) forLabel(String label) {
    switch (label) {
      case '완료':
        return (
          const Color(0xFFF1F5F9),
          const Color(0xFF64748B),
          const Color(0xFFE2E8F0),
        );
      case '근무 중':
        return (
          const Color(0xFFFEF9C3),
          const Color(0xFFA16207),
          const Color(0xFFFDE68A).withValues(alpha: 0.6),
        );
      case '체크 가능':
        return (
          const Color(0xFFEDE9FE),
          const Color(0xFF7C3AED),
          const Color(0xFFDDD6FE).withValues(alpha: 0.7),
        );
      case '근무 예정':
      default:
        return (
          const Color(0xFFEEF2FF),
          const Color(0xFF4F46E5),
          const Color(0xFFE0E7FF).withValues(alpha: 0.8),
        );
    }
  }
}
