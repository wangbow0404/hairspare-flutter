import 'package:flutter/material.dart';

import 'package:hairspare/models/education_enrollment.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/shell_navigation.dart';

/// 근무체크 캘린더 하단 — 교육 신청 카드.
class WorkCheckEducationCard extends StatelessWidget {
  const WorkCheckEducationCard({
    super.key,
    required this.enrollment,
  });

  final EducationEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ShellNavigation.pushEnrollmentDetail(context, enrollment.id);
          },
          borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
          child: Container(
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurpleLight,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
              border: Border.all(
                color: AppTheme.purple100,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: AppTheme.stitchPrimaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '교육 · ${enrollment.title}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        enrollment.isOnline ? '온라인 교육' : '오프라인 교육',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
