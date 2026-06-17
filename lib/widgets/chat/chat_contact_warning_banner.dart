import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/contact_blocker.dart';
import '../../utils/contact_violation_policy.dart';

/// 채팅방 상단 연락처 공유 경고 배너 (짧은 안내만).
class ChatContactWarningBanner extends StatelessWidget {
  const ChatContactWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppTheme.spacing(AppTheme.spacing4),
      padding: AppTheme.spacing(AppTheme.spacing3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.orange50,
            AppTheme.urgentRedLight.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: const Border(
          left: BorderSide(color: AppTheme.orange500, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🚨', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppTheme.spacing2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '연락처 공유 주의사항',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.orange500,
                      ),
                ),
                const SizedBox(height: AppTheme.spacing1 / 2),
                Text(
                  ContactBlocker.bannerMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        height: 1.45,
                        color: AppTheme.orange500.withValues(alpha: 0.95),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 샵 대화·공고 제한 상태 배너.
class ChatShopPenaltyBanner extends StatelessWidget {
  const ChatShopPenaltyBanner({super.key, required this.until});

  final DateTime until;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing3,
      ),
      color: AppTheme.urgentRed,
      child: Text(
        '연락처 공유 위반으로 ${ContactViolationPolicy.shopPenaltyDays}일간 '
        '모든 대화가 제한됩니다. '
        '(${until.month}/${until.day} '
        '${until.hour.toString().padLeft(2, '0')}:'
        '${until.minute.toString().padLeft(2, '0')}까지)',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
      ),
    );
  }
}
