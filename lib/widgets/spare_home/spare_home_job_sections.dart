import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../models/job.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/job_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/job_filter_utils.dart';
import '../../utils/job_popularity.dart';
import '../category_jobs_section.dart';
import '../common/staggered_fade_in.dart';
import '../customer_service_section.dart';
import '../normal_jobs_section.dart';
import '../upcoming_shops_section.dart';
import '../urgent_job_section.dart';
import 'spare_home_ad_banner.dart';
import 'spare_home_filter_chips.dart';

/// 스페어 홈 공고 섹션 묶음 — favoriteMap·sort 1회 계산.
///
/// 급구·하이패스·카테고리 BEST는 결제/노출 우선순위가 있는 영역이라
/// 필터칩과 무관하게 항상 전체 노출. 필터칩은 그 아래 일반 공고 목록에만 적용됨.
/// (기존 별도 "인기 공고" 섹션은 카테고리 BEST의 "추천 BEST" 탭과 중복되어 제거)
class SpareHomeJobSections extends StatefulWidget {
  const SpareHomeJobSections({super.key, required this.onToggleFavorite});

  final Future<void> Function(
    BuildContext context,
    String jobId,
    bool isFavorite,
  )
  onToggleFavorite;

  @override
  State<SpareHomeJobSections> createState() => _SpareHomeJobSectionsState();
}

class _SpareHomeJobSectionsState extends State<SpareHomeJobSections> {
  String _filter = 'all';

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
        final allJobsRaw = [
          ...jobProvider.urgentJobs,
          ...jobProvider.normalJobs,
        ];

        // 결제·노출 우선순위 섹션 — 필터칩과 무관하게 항상 전체 표시.
        final urgentJobs = jobProvider.urgentJobs;
        final hipassJobs = List<Job>.from(
          jobProvider.jobs.where((j) => j.isPremium),
        )..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final popularJobIds = JobPopularity.popularJobIds(allJobsRaw);

        // 필터칩 아래 일반 공고 목록 — 선택된 칩에 따라 필터링(신규 공고도 여기 포함).
        final filteredNormalJobs = JobFilterUtils.apply(
          _filter,
          jobProvider.normalJobs,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StaggeredFadeIn(
              index: 0,
              child: UrgentJobSection(
                urgentJobs: urgentJobs,
                favoriteMap: favoriteMap,
                onJobTap: (job) => _openJobDetail(context, job),
                onFavoriteToggle: (jobId, isFav) =>
                    widget.onToggleFavorite(context, jobId, isFav),
                onViewAll: () =>
                    context.push(AppRoutes.spareHomeJobsPath(filter: 'urgent')),
              ),
            ),
            StaggeredFadeIn(
              index: 1,
              child: UpcomingShopsSection(
                jobs: hipassJobs,
                favoriteMap: favoriteMap,
                onJobTap: (job) => _openJobDetail(context, job),
                onFavoriteToggle: (jobId, isFav) =>
                    widget.onToggleFavorite(context, jobId, isFav),
              ),
            ),
            StaggeredFadeIn(index: 2, child: const SpareHomeAdBanner()),
            StaggeredFadeIn(
              index: 3,
              child: CategoryJobsSection(
                allJobs: jobProvider.jobs,
                selectedRegionId: jobProvider.selectedRegionId,
                favoriteMap: favoriteMap,
                onJobTap: (job) => _openJobDetail(context, job),
                onFavoriteToggle: (jobId, isFav) =>
                    widget.onToggleFavorite(context, jobId, isFav),
                sectionPadding: const EdgeInsets.fromLTRB(
                  AppTheme.spacing4,
                  AppTheme.spacing6,
                  AppTheme.spacing4,
                  AppTheme.spacing4,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            SpareHomeFilterChips(
              selected: _filter,
              onSelected: (v) => setState(() => _filter = v),
            ),
            const SizedBox(height: AppTheme.spacing3),
            StaggeredFadeIn(
              index: 4,
              child: NormalJobsSection(
                jobs: filteredNormalJobs,
                favoriteMap: favoriteMap,
                popularJobIds: popularJobIds,
                onJobTap: (job) => _openJobDetail(context, job),
                onFavoriteToggle: (jobId, isFav) =>
                    widget.onToggleFavorite(context, jobId, isFav),
                onViewAll: () => context.push(AppRoutes.spareHomeJobs),
              ),
            ),
            const CustomerServiceSection(),
            SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
          ],
        );
      },
    );
  }
}
