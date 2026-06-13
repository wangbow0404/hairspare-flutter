import 'package:flutter/material.dart';

import 'package:hairspare/theme/app_theme.dart';

/// 신청 완료 상세 섹션 공통 셸.
class EnrollmentSectionShell extends StatelessWidget {
  const EnrollmentSectionShell({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.accentColor = AppTheme.primaryPurple,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: AppTheme.spacing2),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          child,
        ],
      ),
    );
  }
}
