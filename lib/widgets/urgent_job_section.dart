import 'package:flutter/material.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import 'job_card.dart';

class UrgentJobSection extends StatelessWidget {
  final List<Job> urgentJobs;
  final Function(Job)? onJobTap;
  final Function(String, bool)? onFavoriteToggle;
  final Map<String, bool> favoriteMap;

  const UrgentJobSection({
    super.key,
    required this.urgentJobs,
    this.onJobTap,
    this.onFavoriteToggle,
    this.favoriteMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (urgentJobs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4, // px-4
        vertical: AppTheme.spacing6, // py-6
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Text(
                '🚀',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 24, // text-2xl
                ),
              ),
              SizedBox(width: AppTheme.spacing2), // gap-2
              Text(
                '급구 공고',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20, // text-xl
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary, // text-gray-900
                ),
              ),
              SizedBox(width: AppTheme.spacing2), // gap-2
              // 정보 아이콘
              Container(
                padding: AppTheme.spacing(AppTheme.spacing1), // p-1
                decoration: BoxDecoration(
                  color: AppTheme.borderGray300, // bg-gray-200
                  shape: BoxShape.circle, // rounded-full
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 16, // w-4 h-4
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4), // mb-4

          // 급구 공고 리스트
          Column(
            children: urgentJobs.take(5).map((job) {
              return JobCard(
                job: job,
                isUrgent: true,
                isFavorite: favoriteMap[job.id] ?? false,
                onTap: () => onJobTap?.call(job),
                onFavoriteToggle: onFavoriteToggle != null
                    ? () => onFavoriteToggle!(job.id, !(favoriteMap[job.id] ?? false))
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
