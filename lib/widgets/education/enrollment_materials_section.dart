import 'package:flutter/material.dart';

import 'package:hairspare/models/education_material.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/widgets/challenge/challenge_url_launcher.dart';
import 'package:hairspare/widgets/education/enrollment_section_shell.dart';

/// 교육 전 자료 (PDF 등) 다운로드/열기.
class EnrollmentMaterialsSection extends StatelessWidget {
  const EnrollmentMaterialsSection({
    super.key,
    required this.materials,
  });

  final List<EducationMaterial>? materials;

  @override
  Widget build(BuildContext context) {
    final list = materials ?? const [];
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }

    return EnrollmentSectionShell(
      title: '교육 전 자료',
      icon: Icons.folder_outlined,
      child: Column(
        children: [
          for (var i = 0; i < list.length; i++) ...[
            if (i > 0) const SizedBox(height: AppTheme.spacing2),
            Material(
              color: AppTheme.backgroundGray,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
              child: InkWell(
                onTap: () => launchChallengeExternalUrl(context, list[i].url),
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                child: Padding(
                  padding: AppTheme.spacing(AppTheme.spacing3),
                  child: Row(
                    children: [
                      Icon(
                        list[i].fileType == 'pdf'
                            ? Icons.picture_as_pdf_outlined
                            : Icons.description_outlined,
                        color: AppTheme.primaryPurple,
                      ),
                      const SizedBox(width: AppTheme.spacing3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              list[i].title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${list[i].fileType.toUpperCase()} · 탭하여 열기',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
