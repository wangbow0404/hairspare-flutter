import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../theme/app_theme.dart';
import 'stitch/stitch_compact_job_card.dart';
import 'stitch/stitch_section_header.dart';

/// Stitch 스타일 급구 공고 섹션 — 가로 스크롤 카드.
class UrgentJobSection extends StatelessWidget {
  const UrgentJobSection({
    super.key,
    required this.urgentJobs,
    this.onJobTap,
    this.onFavoriteToggle,
    this.favoriteMap = const {},
    this.onViewAll,
  });

  final List<Job> urgentJobs;
  final void Function(Job)? onJobTap;
  final void Function(String, bool)? onFavoriteToggle;
  final Map<String, bool> favoriteMap;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    if (urgentJobs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: AppTheme.spacing4,
        bottom: AppTheme.spacing2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing4,
            ),
            child: StitchSectionHeader(
              title: '놓치면 아쉬운 ',
              titleHighlight: '급구 공고 ⏰',
              subtitle: '지금 당장 스페어가 필요해요!',
              onViewAll: onViewAll,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          SizedBox(
            height: 188,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
              ),
              itemCount: urgentJobs.length.clamp(0, 10),
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppTheme.spacing4),
              itemBuilder: (context, index) {
                final job = urgentJobs[index];
                final isFavorite = favoriteMap[job.id] ?? false;
                return StitchCompactJobCard(
                  job: job,
                  isFavorite: isFavorite,
                  onTap: () => onJobTap?.call(job),
                  onFavoriteToggle: onFavoriteToggle != null
                      ? () => onFavoriteToggle!(
                            job.id,
                            !isFavorite,
                          )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
