import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../screens/spare/education_screen.dart';
import '../../theme/app_theme.dart';
import '../common/app_network_image.dart';

/// 교육 목록 카드 — 썸네일 + 뱃지 + 메타.
class StitchListEducationCard extends StatelessWidget {
  const StitchListEducationCard({
    super.key,
    required this.education,
    this.onTap,
  });

  final Education education;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: AppNetworkImage(
                    imageUrl: education.imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 800,
                    fallbackIcon: Icons.school_rounded,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppTheme.spacing2,
                      runSpacing: AppTheme.spacing1,
                      children: [
                        if (education.isUrgent) const _UrgentBadge(),
                        _OnlineBadge(isOnline: education.isOnline),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing3),
                    Text(
                      education.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.stitchTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      education.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppTheme.stitchTextSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacing3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppTheme.stitchTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${education.province}${education.district != null ? ' ${education.district}' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.stitchTextSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing3),
                        const Icon(
                          Icons.bolt_outlined,
                          size: 16,
                          color: AppTheme.stitchTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '에너지 ${education.energyCost}개',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.stitchTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 16,
                          color: AppTheme.stitchTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '신청 ${education.applicants}/${education.maxApplicants}명',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.stitchTextSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '마감: ${DateFormat('yyyy-MM-dd').format(education.deadline)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.stitchTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UrgentBadge extends StatelessWidget {
  const _UrgentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: AppTheme.urgentRed,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🚀', style: TextStyle(fontSize: 12)),
          SizedBox(width: 4),
          Text(
            '급구',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: isOnline
            ? const Color(0xFFDBEAFE)
            : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        isOnline ? '온라인' : '오프라인',
        style: TextStyle(
          color: isOnline
              ? const Color(0xFF1D4ED8)
              : const Color(0xFF15803D),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
