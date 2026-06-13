import 'package:flutter/material.dart';

import 'package:hairspare/models/education_enrollment.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/widgets/challenge/challenge_url_launcher.dart';
import 'package:hairspare/widgets/education/education_ui_kit.dart';
import 'package:hairspare/widgets/education/enrollment_section_shell.dart';

/// 오프라인 교육 장소 · 지도.
class EnrollmentVenueSection extends StatelessWidget {
  const EnrollmentVenueSection({super.key, required this.enrollment});

  final EducationEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    final address = enrollment.venueAddress ??
        '${enrollment.province ?? ''} ${enrollment.district ?? ''}'.trim();

    return EnrollmentSectionShell(
      title: '교육 장소',
      icon: Icons.location_on_outlined,
      accentColor: AppTheme.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (address.isNotEmpty)
            Text(
              address,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
            ),
          const SizedBox(height: AppTheme.spacing3),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.borderGray),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 36,
                  color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 8),
                const Text(
                  '지도 미리보기',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          EducationGradientPrimaryButton(
            label: '지도에서 보기',
            icon: Icons.open_in_new,
            onPressed: () {
              final query = Uri.encodeComponent(address);
              launchChallengeExternalUrl(
                context,
                'https://maps.google.com/?q=$query',
              );
            },
            gradientColors: const [AppTheme.primaryBlue],
          ),
        ],
      ),
    );
  }
}
