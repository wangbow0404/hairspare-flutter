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
        final topPopularJobs = JobPopularity.topPopular(allJobs);
        final newJobs = List<Job>.from(allJobs)
          ..sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );
        final topNewJobs = newJobs.take(10).toList();
        final allJobsForUpcoming = jobProvider.normalJobs.isNotEmpty
            ? jobProvider.normalJobs
            : jobProvider.urgentJobs;
        final upcomingJobs = List<Job>.from(allJobsForUpcoming)
          ..sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );
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
