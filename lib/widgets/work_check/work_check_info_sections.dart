import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/schedule_session_audience.dart';
import '../../view_models/work_check_view_model.dart';

/// 미체크 근무가 있을 때 상단에 노출되는 안내 배너.
class WorkCheckUncheckedBanner extends StatelessWidget {
  const WorkCheckUncheckedBanner({
    super.key,
    required this.audience,
    required this.count,
    required this.onTap,
  });

  final ScheduleSessionAudience audience;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.backgroundWhite,
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
          child: Container(
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: AppTheme.orange500.withValues(alpha: 0.08),
              border: Border.all(color: AppTheme.orange500, width: 1),
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.orange500.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.how_to_reg_outlined,
                    size: 22,
                    color: AppTheme.orange500,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        audience.uncheckedBannerTitle(count),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing1),
                      Text(
                        audience.uncheckedBannerSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppTheme.orange500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 스페어 모드: 하단 "근무 보너스 팁" 카드.
class WorkCheckBonusTipSection extends StatelessWidget {
  const WorkCheckBonusTipSection({super.key, required this.vm});

  final WorkCheckViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          top: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
      ),
      child: Container(
        padding: AppTheme.spacing(AppTheme.spacing4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundGradientStart,
              AppTheme.backgroundGradientMiddle,
              AppTheme.backgroundGradientEnd,
            ],
          ),
          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '근무 보너스 팁',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacing1),
                      Text(
                        '매일 출석하면 최대 에너지 3개를 받을 수 있어요!',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(
                              fontSize: 14,
                              color: AppTheme.textGray700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing3),
            Container(
              padding: AppTheme.spacing(AppTheme.spacing3),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
              ),
              child: Row(
                children: [
                  const Text('💰', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: AppTheme.spacing3),
                  Expanded(
                    child: Text(
                      vm.consecutiveDays >= 30
                          ? '$vm.consecutiveDays일을 연속 출근하면 에너지 3개! 최대 3만원을 아낄 수 있어요!'
                          : vm.consecutiveDays >= 20
                          ? '$vm.consecutiveDays일을 연속 출근하면 에너지 2개! 최대 2만원을 아낄 수 있어요!'
                          : vm.consecutiveDays >= 10
                          ? '$vm.consecutiveDays일을 연속 출근하면 에너지 1개! 최대 1만원을 아낄 수 있어요!'
                          : '30일을 연속 출근하면 에너지 3개! 최대 3만원을 아낄 수 있어요!',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(
                            fontSize: 14,
                            color: AppTheme.textGray700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 모델 모드: 하단 팁 배너.
class WorkCheckModelTipSection extends StatelessWidget {
  const WorkCheckModelTipSection({super.key, required this.audience});

  final ScheduleSessionAudience audience;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          top: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
      ),
      child: Container(
        padding: AppTheme.spacing(AppTheme.spacing4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundGradientStart,
              AppTheme.backgroundGradientMiddle,
              AppTheme.backgroundGradientEnd,
            ],
          ),
          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: Text(
                    audience.tipBannerMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: AppTheme.textGray700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _workCheckInfoItem(BuildContext context, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '•',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 14,
          color: AppTheme.stitchPrimaryContainer,
        ),
      ),
      const SizedBox(width: AppTheme.spacing2),
      Expanded(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    ],
  );
}

/// 하단 안내(불릿 리스트) 섹션.
class WorkCheckScheduleInfoSection extends StatelessWidget {
  const WorkCheckScheduleInfoSection({
    super.key,
    required this.title,
    required this.lines,
  });

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: AppTheme.spacing6,
        bottom: AppTheme.spacing2,
        left: AppTheme.spacing4,
        right: AppTheme.spacing4,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          top: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const SizedBox(height: AppTheme.spacing3),
            _workCheckInfoItem(context, lines[i]),
          ],
        ],
      ),
    );
  }
}
