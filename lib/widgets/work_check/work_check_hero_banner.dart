import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/schedule_session_audience.dart';

/// 연속 근무 이벤트 배너 (a안 — berry soft surface).
class WorkCheckHeroBanner extends StatelessWidget {
  const WorkCheckHeroBanner({
    super.key,
    required this.isModelMode,
    required this.titleInfo,
    required this.audience,
    required this.displayDays,
  });

  final bool isModelMode;
  final Map<String, dynamic> titleInfo;
  final ScheduleSessionAudience audience;
  final int displayDays;

  @override
  Widget build(BuildContext context) {
    if (!isModelMode) {
      return _buildStreakBanner(context);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing6,
        horizontal: AppTheme.spacing4,
      ),
      decoration: const BoxDecoration(
        color: HairSpareColors.brandPrimarySoft,
        border: Border(
          bottom: BorderSide(color: HairSpareColors.border),
        ),
      ),
      child: Column(
        children: [
          Text(
            titleInfo['emoji'] as String,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            titleInfo['title'] as String,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: HairSpareColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing1),
          Text(
            titleInfo['subtitle'] as String,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: HairSpareColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing3),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing4,
              vertical: AppTheme.spacing2,
            ),
            decoration: BoxDecoration(
              color: HairSpareColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(color: HairSpareColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleInfo['pillLabel'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: HairSpareColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2),
                Text(
                  titleInfo['pillValue'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: HairSpareColors.brandPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// PDF 03 — 「연속 근무 이벤트 X/10」 도트 진행바 한 장으로 정리 (근무체크 시작 타이틀 +
  /// 근무 보상 카드는 여기 흡수됨, 중복 섹션 제거).
  Widget _buildStreakBanner(BuildContext context) {
    final remaining = 10 - displayDays;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing4,
        horizontal: AppTheme.spacing4,
      ),
      decoration: const BoxDecoration(
        color: HairSpareColors.brandPrimarySoft,
        border: Border(
          bottom: BorderSide(color: HairSpareColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '연속 근무 이벤트',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: HairSpareColors.textPrimary,
                ),
              ),
              Text(
                '$displayDays/10',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: HairSpareColors.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing3),
          Row(
            children: List.generate(10, (index) {
              final filled = index < displayDays;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == 9 ? 0 : AppTheme.spacing1,
                  ),
                  height: 6,
                  decoration: BoxDecoration(
                    color: filled
                        ? HairSpareColors.brandPrimary
                        : HairSpareColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            remaining > 0
                ? '$remaining번만 더 근무하면 포인트가 지급돼요'
                : '포인트가 지급됐어요!',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: HairSpareColors.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
