import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 스케줄 리스트 카드 공통 셸 — 부드러운 그림자·미세 그라데이션.
class ScheduleListCardShell extends StatelessWidget {
  const ScheduleListCardShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.stitchSoftShadow,
      ),
      child: child,
    );
  }
}
