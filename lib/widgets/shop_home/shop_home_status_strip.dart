import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/home_text_styles.dart';

/// 샵 홈 — 진행중 공고 / 대기 지원자 / 오늘의 매칭 상태 카드 Row.
class ShopHomeStatusStrip extends StatelessWidget {
  const ShopHomeStatusStrip({
    super.key,
    required this.activeJobCount,
    required this.pendingApplicantsCount,
    required this.todayModelMatchingCount,
    required this.onActiveJobsTap,
    required this.onPendingApplicantsTap,
    required this.onModelMatchingTap,
  });

  final int activeJobCount;
  final int pendingApplicantsCount;
  final int todayModelMatchingCount;
  final VoidCallback onActiveJobsTap;
  final VoidCallback onPendingApplicantsTap;
  final VoidCallback onModelMatchingTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundWhite,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing2,
      ),
      child: Row(
        children: [
          Expanded(
            child: _ShopHomeStatusCard(
              value: '$activeJobCount',
              label: '진행중 공고',
              onTap: onActiveJobsTap,
            ),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: _ShopHomeStatusCard(
              value: '$pendingApplicantsCount',
              label: '대기 지원자',
              onTap: onPendingApplicantsTap,
            ),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: _ShopHomeStatusCard(
              value: '$todayModelMatchingCount',
              label: '오늘의 매칭',
              onTap: onModelMatchingTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopHomeStatusCard extends StatelessWidget {
  const _ShopHomeStatusCard({
    required this.value,
    required this.label,
    required this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundWhite,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.borderGray),
            boxShadow: AppTheme.stitchSoftShadow,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2,
            vertical: AppTheme.spacing3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: HomeTextStyles.dashboardValueOnWhite,
              ),
              const SizedBox(height: AppTheme.spacing1),
              Text(
                label,
                style: HomeTextStyles.dashboardLabelOnWhite,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
