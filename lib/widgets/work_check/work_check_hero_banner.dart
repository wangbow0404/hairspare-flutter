import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/schedule_session_audience.dart';

/// 근무체크 / 모델 일정 화면 상단 히어로 배너 (그라데이션 + 이모지 + 스트릭 pill).
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing8,
        horizontal: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7800CE),
            Color(0xFF9333EA),
            Color(0xFFEC4899),
          ],
        ),
      ),
      child: Column(
        children: [
          // 배경 장식
          Stack(
            children: [
              Positioned(
                top: AppTheme.spacing4,
                left: AppTheme.spacing4,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: AppTheme.spacing8,
                right: AppTheme.spacing8,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    titleInfo['emoji'] as String,
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: AppTheme.spacing3),
                  Text(
                    titleInfo['title'] as String,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    titleInfo['subtitle'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Container(
                    padding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing5,
                      vertical: AppTheme.spacing2 + AppTheme.spacing1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppTheme.borderRadius(
                        AppTheme.radiusFull,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isModelMode
                              ? titleInfo['pillLabel'] as String
                              : audience.streakPillLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(width: AppTheme.spacing2),
                        Text(
                          isModelMode
                              ? titleInfo['pillValue'] as String
                              : '$displayDays일',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
