import 'package:flutter/material.dart';

import '../../models/shop_tier.dart';
import '../../theme/app_theme.dart';

/// 등급 혜택 상세 안내 (AlertDialog). 기획 연결 시 `showShopTierBenefitsModal(context, tierInfo)` 호출.
void showShopTierBenefitsModal(BuildContext context, ShopTierInfo tierInfo) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Row(
        children: [
          Text(
            tierInfo.currentTier.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: AppTheme.spacing2),
          Expanded(
            child: Text(
              '${tierInfo.currentTier.name} 등급 혜택',
              style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(tierInfo.currentTier.colorValue),
                  ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing3),
              decoration: BoxDecoration(
                color: Color(tierInfo.currentTier.colorValue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 등급',
                    style: Theme.of(dialogContext).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    '완료 스케줄: ${tierInfo.completedSchedules}개',
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),
                  Text(
                    '받은 응원: ${tierInfo.thumbsUpReceived}개',
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),
                  Text(
                    '최대 공고 등록: ${tierInfo.maxJobPosts == 999 ? "무제한" : "${tierInfo.maxJobPosts}개"}',
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              '현재 혜택',
              style: Theme.of(dialogContext).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            ...tierInfo.currentTier.benefits.map((benefit) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacing1),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Color(tierInfo.currentTier.colorValue),
                    ),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(
                      child: Text(
                        benefit,
                        style: Theme.of(dialogContext).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (tierInfo.currentTier.getNextTier() != null) ...[
              const SizedBox(height: AppTheme.spacing4),
              const Divider(),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                '다음 등급: ${tierInfo.currentTier.getNextTier()!.emoji} ${tierInfo.currentTier.getNextTier()!.name}',
                style: Theme.of(dialogContext).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Color(tierInfo.currentTier.getNextTier()!.colorValue),
                    ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              Text(
                '필요 조건:',
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing1),
              Text(
                '• 완료 스케줄 ${tierInfo.currentTier.getNextTier()!.minCompletedSchedules}개 이상',
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
              Text(
                '• 또는 응원 ${tierInfo.currentTier.getNextTier()!.minThumbsUp}개 이상',
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
              const SizedBox(height: AppTheme.spacing2),
              Text(
                '다음 등급 혜택:',
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing1),
              ...tierInfo.currentTier.getNextTier()!.benefits.map((benefit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.star_outline,
                        size: 16,
                        color: Color(tierInfo.currentTier.getNextTier()!.colorValue),
                      ),
                      const SizedBox(width: AppTheme.spacing2),
                      Expanded(
                        child: Text(
                          benefit,
                          style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}
