import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 모델 모드: 시술 일정 요약 섹션 (예정 건수 + 진행 바).
class WorkCheckModelScheduleSummary extends StatelessWidget {
  const WorkCheckModelScheduleSummary({super.key, required this.upcomingCount});

  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    const maxDisplay = 5;
    final progress = (upcomingCount / maxDisplay).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppTheme.backgroundWhite),
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '시술 일정 요약',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            '확정·조율 중인 시술 일정을 한눈에 확인하세요.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Container(
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '예정 시술',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textGray700,
                      ),
                    ),
                    Text(
                      '$upcomingCount건',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.stitchPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing4),
                ClipRRect(
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFEEF0F3),
                    color: AppTheme.stitchPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3),
                Text(
                  upcomingCount == 0
                      ? '매칭된 시술 일정이 여기에 표시돼요.'
                      : '달력에서 날짜를 선택해 상세 일정을 확인하세요.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
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

/// 스페어 모드: 근무 보상(연속 근무 에너지 진행률) 섹션.
class WorkCheckRewardSection extends StatelessWidget {
  const WorkCheckRewardSection({super.key, required this.displayDays});

  final int displayDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppTheme.backgroundWhite),
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '근무 보상',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            '노쇼 없이 10회 연속 근무하면 에너지 1개를 받아요!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Container(
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth;
                final fillWidth = (displayDays / 10) * barWidth;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '에너지 진행률',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textGray700,
                              ),
                        ),
                        Text(
                          '$displayDays / 10회',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.stitchPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF0F3),
                            borderRadius: AppTheme.borderRadius(
                              AppTheme.radiusFull,
                            ),
                          ),
                          child: Row(
                            children: [
                              ...List.generate(9, (index) {
                                return Expanded(
                                  child: Container(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        width: 3,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: AppTheme.borderGray300,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        if (displayDays > 0)
                          Positioned(
                            left: 0,
                            top: 0,
                            child: SizedBox(
                              width: fillWidth.clamp(0.0, barWidth),
                              height: 60,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.stitchPrimaryContainer,
                                      AppTheme.stitchPrimaryContainer,
                                    ],
                                  ),
                                  borderRadius: AppTheme.borderRadius(
                                    AppTheme.radiusFull,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (displayDays > 0)
                          Positioned(
                            left: (fillWidth - 32).clamp(
                              0.0,
                              barWidth - 64,
                            ),
                            top: 0,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.stitchPrimaryContainer,
                                    AppTheme.stitchPrimaryContainer,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '⚡',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
