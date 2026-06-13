import 'package:flutter/material.dart';

import 'package:hairspare/models/education_enrollment.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/widgets/challenge/challenge_url_launcher.dart';
import 'package:hairspare/widgets/education/education_ui_kit.dart';
import 'package:hairspare/widgets/education/enrollment_section_shell.dart';

/// 온라인 교육 접속 안내.
class EnrollmentOnlineSection extends StatelessWidget {
  const EnrollmentOnlineSection({super.key, required this.enrollment});

  final EducationEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    final url = enrollment.meetingUrl;
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    return EnrollmentSectionShell(
      title: '온라인 접속',
      icon: Icons.videocam_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '교육 시작 시간에 아래 버튼으로 접속해 주세요.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          EducationGradientPrimaryButton(
            label: '교육 접속하기',
            icon: Icons.link,
            onPressed: () => launchChallengeExternalUrl(context, url),
            gradientColors: const [AppTheme.primaryPurple],
          ),
        ],
      ),
    );
  }
}
