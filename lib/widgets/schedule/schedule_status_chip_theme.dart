import 'package:flutter/material.dart';

import '../../theme/hairspare_colors.dart';

/// 스케줄·일정 태그 — a안 기능색.
abstract final class ScheduleStatusChipTheme {
  ScheduleStatusChipTheme._();

  static (Color bg, Color fg, Color? border) forLabel(String label) {
    switch (label) {
      case '완료':
      case '정산 완료':
      case '정산완료':
        return (
          HairSpareColors.statusSuccessBg,
          HairSpareColors.statusSuccess,
          HairSpareColors.statusSuccess.withValues(alpha: 0.25),
        );
      case '교육':
        return (
          HairSpareColors.statusEducationBg,
          HairSpareColors.statusEducation,
          HairSpareColors.statusEducation.withValues(alpha: 0.25),
        );
      case '모델매칭':
        return (
          HairSpareColors.statusMatchingBg,
          HairSpareColors.statusMatching,
          HairSpareColors.statusMatching.withValues(alpha: 0.25),
        );
      case '근무 중':
        return (
          HairSpareColors.brandPrimarySoft,
          HairSpareColors.brandPrimary,
          HairSpareColors.brandPrimary.withValues(alpha: 0.2),
        );
      case '근무 예정':
      case '근무예정':
      default:
        return (
          HairSpareColors.surfaceMuted,
          HairSpareColors.textStrongAlt,
          HairSpareColors.border,
        );
    }
  }
}
