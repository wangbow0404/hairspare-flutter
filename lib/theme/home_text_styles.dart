import 'package:flutter/material.dart';

import 'app_theme.dart';

/// 스페어·미용실 홈에서 [JobCard], 섹션 헤더([UrgentJobSection], [NormalJobsSection])와
/// 동일한 수치를 쓰는 공통 타이포. 한곳에서만 조정해 드리프트를 막습니다.
abstract final class HomeTextStyles {
  /// 섹션 제목 — `fontSize: 20`, bold, `textPrimary`
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
    height: 1.25,
  );

  /// 카드 내 강조 제목 (JobCard 미용실명 등) — 14, semibold
  static const TextStyle homeCardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  );

  /// 카드 메타·부가 설명 — 12, `textSecondary`
  static const TextStyle homeCardMeta = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondary,
    height: 1.35,
  );

  /// 작은 태그 라벨 — 12, medium (색은 호출부에서 덧씀)
  static const TextStyle homeCardTag = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// 대시보드 그라데이션 카드 숫자
  static const TextStyle dashboardValueOnGradient = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  /// 대시보드 그라데이션 카드 라벨
  static final TextStyle dashboardLabelOnGradient = TextStyle(
    fontSize: 14,
    color: Colors.white.withValues(alpha: 0.9),
  );

  /// 퀵 액션 제목 (카드 제목과 동일 위계)
  static const TextStyle quickActionTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );

  /// 퀵 액션 부제
  static const TextStyle quickActionSubtitle = TextStyle(
    fontSize: 12,
    color: AppTheme.textSecondary,
  );

  /// 섹션 헤더 옆 배지 (예: HOT)
  static const TextStyle sectionBadge = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
}
