import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../models/job.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/job_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/job_popularity.dart';
import '../../utils/jobs_list_sort.dart';
import '../category_jobs_section.dart';
import '../customer_service_section.dart';
import '../new_jobs_section.dart';
import '../normal_jobs_section.dart';
import '../popular_jobs_section.dart';
import '../upcoming_shops_section.dart';
import '../urgent_job_section.dart';

/// 스페어 홈 공고 섹션 묶음 — favoriteMap·sort 1회 계산.
class SpareHomeJobSections extends StatelessWidget {
  const SpareHomeJobSections({
    super.key,
    required this.onToggleFavorite,
  });

  final Future<void> Function(BuildContext context, String jobId, bool isFavorite)
      onToggleFavorite;

  static Map<String, bool> _favoriteMap(Set<String> ids) {
    return {for (final id in ids) id: true};
  }

  static void _openJobDetail(BuildContext context, Job job) {
    if (!context.mounted) return;
    context.push(AppRoutes.spareHomeJobDetail(job.id));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<JobProvider, FavoriteProvider>(
      builder: (context, jobProvider, favoriteProvider, _) {
        final favoriteMap = _favoriteMap(favoriteProvider.favoriteJobIds);
        final allJobs = [...jobProvider.urgentJobs, ...jobProvider.normalJobs];

        // 섹션 간 중복 제거: 위 섹션에서 사용된 ID는 아래 섹션에서 제외
        final shownIds = <String>{};

        // 긴급 공고 ID를 먼저 예약
        shownIds.addAll(jobProvider.urgentJobs.map((j) => j.id));

        // 인기 공고: 긴급 공고 제외 후 선택
        final topPopularJobs = JobPopularity.topPopular(
          allJobs.where((j) => !shownIds.contains(j.id)).toList(),
        );
        shownIds.addAll(topPopularJobs.map((j) => j.id));

        // 신규 공고: 앞 섹션에서 사용된 것 제외
        final newJobs = List<Job>.from(allJobs.where((j) => !shownIds.contains(j.id)))
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final topNewJobs = newJobs.take(10).toList();
        shownIds.addAll(topNewJobs.map((j) => j.id));

        // 다가오는 샵: 오픈예정 결제 공고만 노출
        final allJobsForUpcoming = jobProvider.normalJobs.isNotEmpty
            ? jobProvider.normalJobs
            : jobProvider.urgentJobs;
        final upcomingJobs = List<Job>.from(
          allJobsForUpcoming.where(
            (j) => !shownIds.contains(j.id) && j.isOpeningSoon,
          ),
        )..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final topUpcomingJobs = upcomingJobs.take(3).toList();

        final popularJobIds = JobPopularity.popularJobIds(allJobs);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UrgentJobSection(
              urgentJobs: jobProvider.urgentJobs,
              favoriteMap: favoriteMap,
              onJobTap: (job) => _openJobDetail(context, job),
              onFavoriteToggle: (jobId, isFav) =>
                  onToggleFavorite(context, jobId, isFav),
              onViewAll: () => context.push(
                AppRoutes.spareHomeJobsPath(filter: 'urgent'),
              ),
            ),
            CategoryJobsSection(
              allJobs: jobProvider.jobs,
              selectedRegionId: jobProvider.selectedRegionId,
              favoriteMap: favoriteMap,
              onJobTap: (job) => _openJobDetail(context, job),
              onFavoriteToggle: (jobId, isFav) =>
                  onToggleFavorite(context, jobId, isFav),
              sectionPadding: const EdgeInsets.fromLTRB(
                AppTheme.spacing4,
                AppTheme.spacing1,
                AppTheme.spacing4,
                AppTheme.spacing4,
              ),
            ),
            PopularJobsSection(
              jobs: topPopularJobs,
              favoriteMap: favoriteMap,
              onJobTap: (job) => _openJobDetail(context, job),
              onFavoriteToggle: (jobId, isFav) =>
                  onToggleFavorite(context, jobId, isFav),
              onViewAll: () => context.push(
                AppRoutes.spareHomeJobsPath(
                  sort: JobsListSortMode.popular.name,
                ),
              ),
            ),
            NewJobsSection(
              jobs: topNewJobs,
              favoriteMap: favoriteMap,
              onJobTap: (job) => _openJobDetail(context, job),
              onFavoriteToggle: (jobId, isFav) =>
                  onToggleFavorite(context, jobId, isFav),
              onViewAll: () => context.push(
                AppRoutes.spareHomeJobsPath(
                  sort: JobsListSortMode.latest.name,
                ),
              ),
            ),
            UpcomingShopsSection(
              jobs: topUpcomingJobs,
              favoriteMap: favoriteMap,
              onJobTap: (job) => _openJobDetail(context, job),
              onFavoriteToggle: (jobId, isFav) =>
                  onToggleFavorite(context, jobId, isFav),
            ),
            NormalJobsSection(
              jobs: jobProvider.normalJobs,
              favoriteMap: favoriteMap,
              popularJobIds: popularJobIds,
              onJobTap: (job) => _openJobDetail(context, job),
              onFavoriteToggle: (jobId, isFav) =>
                  onToggleFavorite(context, jobId, isFav),
              onViewAll: () => context.push(AppRoutes.spareHomeJobs),
            ),
            const CustomerServiceSection(),
            SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
          ],
        );
      },
    );
  }
}
