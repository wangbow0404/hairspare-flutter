import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_navigation.dart';
import '../../models/job.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/job_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/category_jobs_section.dart';
import '../../widgets/customer_service_section.dart';
import '../../widgets/new_jobs_section.dart';
import '../../widgets/normal_jobs_section.dart';
import '../../widgets/popular_jobs_section.dart';
import '../../widgets/upcoming_shops_section.dart';
import '../../widgets/urgent_job_section.dart';
import '../../screens/spare/challenge_screen.dart';
import '../../screens/spare/education_screen.dart';
import '../../screens/spare/energy_screen.dart';
import '../../screens/spare/job_detail_screen.dart';
import '../../screens/spare/jobs_list_screen.dart';
import '../../screens/spare/points_screen.dart';
import '../../screens/spare/region_select_screen.dart';
import '../../screens/spare/work_check_screen.dart';
import 'spare_home_app_bar.dart';

/// 스페어 홈 본문(헤더·배너·카테고리·공고 섹션).
class SpareHomeScrollView extends StatelessWidget {
  const SpareHomeScrollView({super.key, required this.scrollController});

  final ScrollController scrollController;

  static Future<void> _toggleFavorite(BuildContext context, String jobId, bool isFavorite) async {
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    final success = await favoriteProvider.toggleFavorite(jobId);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(favoriteProvider.error ?? '찜 상태 업데이트에 실패했습니다.'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  static void _openJobDetail(BuildContext context, Job job) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => JobDetailScreen(jobId: job.id),
      ),
    );
  }

  static void _onBannerTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const JobsListScreen(filter: 'urgent'),
          ),
        );
        break;
      case 1:
        AppNavigation.goSpareMainTab(context, 1);
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (context) => const EnergyScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (context) => const EducationScreen()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 44 + MediaQuery.paddingOf(context).top,
            decoration: const BoxDecoration(
              color: AppTheme.backgroundWhite,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderGray,
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top,
              left: AppTheme.spacing4,
              right: AppTheme.spacing4,
            ),
            child: SizedBox(
              height: 44,
              child: SpareHomeAppBarRow(scrollController: scrollController),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: BannerCarousel(
                      height: 240,
                      bannerImages: const [
                        'assets/images/banners/banner1.jpg',
                        'assets/images/banners/banner2.jpg',
                        'assets/images/banners/banner3.jpg',
                        'assets/images/banners/banner4.jpg',
                      ],
                      onBannerTap: (i) => _onBannerTap(context, i),
                    ),
                  ),
                ),
              ),
              Consumer<JobProvider>(
                builder: (context, jobProvider, _) {
                  if (jobProvider.isLoading) {
                    return const SizedBox(
                      height: 400,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (jobProvider.error != null) {
                    return SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '오류가 발생했습니다',
                              style: TextStyle(color: AppTheme.urgentRed),
                            ),
                            const SizedBox(height: AppTheme.spacing4),
                            ElevatedButton(
                              onPressed: () => jobProvider.refreshJobs(),
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CategoryGrid(
                        padding: const EdgeInsets.only(top: 0, bottom: AppTheme.spacing2),
                        categories: [
                          CategoryItem(
                            emoji: '📋',
                            label: '공고별',
                            has3DEffect: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => const JobsListScreen(),
                                ),
                              );
                            },
                          ),
                          CategoryItem(
                            emoji: '📅',
                            label: '스케줄표',
                            onTap: () {
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      const WorkCheckScreen(),
                                ),
                              );
                            },
                          ),
                          CategoryItem(
                            emoji: '🏪',
                            label: '스토어',
                            has3DEffect: true,
                            onTap: () {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('준비 중'),
                                  content: const Text('스토어 기능은 준비 중입니다.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('확인'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          CategoryItem(
                            emoji: '💰',
                            label: '+포인트',
                            has3DEffect: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => const PointsScreen(),
                                ),
                              );
                            },
                          ),
                          CategoryItem(
                            emoji: '🗺️',
                            label: '공간대여',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => const RegionSelectScreen(),
                                ),
                              );
                            },
                          ),
                          CategoryItem(
                            emoji: '📚',
                            label: '교육',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => const EducationScreen(),
                                ),
                              );
                            },
                          ),
                          CategoryItem(
                            emoji: '🎯',
                            label: '챌린지참여',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => const ChallengeScreen(),
                                ),
                              );
                            },
                          ),
                          CategoryItem(
                            emoji: '💡',
                            label: '커넥트',
                            onTap: () {
                              showDialog<void>(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                                  ),
                                  title: const Text('준비 중'),
                                  content: const Text('커넥트 기능은 준비 중입니다.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('확인'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Consumer<JobProvider>(
                        builder: (context, jobProvider2, _) {
                          return Consumer<FavoriteProvider>(
                            builder: (context, favoriteProvider, _) {
                              final favoriteMap = favoriteProvider.favoriteJobIds.fold<Map<String, bool>>(
                                {},
                                (map, jobId) => map..[jobId] = true,
                              );
                              return CategoryJobsSection(
                                allJobs: jobProvider2.jobs,
                                selectedRegionId: jobProvider2.selectedRegionId,
                                favoriteMap: favoriteMap,
                                onJobTap: (job) => _openJobDetail(context, job),
                                onFavoriteToggle: (jobId, isFav) => _toggleFavorite(context, jobId, isFav),
                                sectionPadding: const EdgeInsets.fromLTRB(
                                  AppTheme.spacing4,
                                  AppTheme.spacing1,
                                  AppTheme.spacing4,
                                  AppTheme.spacing4,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Consumer<FavoriteProvider>(
                        builder: (context, favoriteProvider, _) {
                          final favoriteMap = favoriteProvider.favoriteJobIds.fold<Map<String, bool>>(
                            {},
                            (map, jobId) => map..[jobId] = true,
                          );
                          return UrgentJobSection(
                            urgentJobs: jobProvider.urgentJobs,
                            favoriteMap: favoriteMap,
                            onJobTap: (job) => _openJobDetail(context, job),
                            onFavoriteToggle: (jobId, isFav) => _toggleFavorite(context, jobId, isFav),
                          );
                        },
                      ),
                      Consumer<FavoriteProvider>(
                        builder: (context, favoriteProvider, _) {
                          final favoriteMap = favoriteProvider.favoriteJobIds.fold<Map<String, bool>>(
                            {},
                            (map, jobId) => map..[jobId] = true,
                          );
                          final allJobs = [...jobProvider.urgentJobs, ...jobProvider.normalJobs];
                          final popularJobs = List<Job>.from(allJobs)
                            ..sort((a, b) => b.requiredCount.compareTo(a.requiredCount));
                          final topPopularJobs = popularJobs.take(10).toList();

                          return PopularJobsSection(
                            jobs: topPopularJobs,
                            favoriteMap: favoriteMap,
                            onJobTap: (job) => _openJobDetail(context, job),
                            onFavoriteToggle: (jobId, isFav) => _toggleFavorite(context, jobId, isFav),
                          );
                        },
                      ),
                      Consumer<FavoriteProvider>(
                        builder: (context, favoriteProvider, _) {
                          final favoriteMap = favoriteProvider.favoriteJobIds.fold<Map<String, bool>>(
                            {},
                            (map, jobId) => map..[jobId] = true,
                          );
                          final allJobs = [...jobProvider.urgentJobs, ...jobProvider.normalJobs];
                          final newJobs = List<Job>.from(allJobs)..sort((a, b) {
                              final aTime = a.createdAt.millisecondsSinceEpoch;
                              final bTime = b.createdAt.millisecondsSinceEpoch;
                              return bTime.compareTo(aTime);
                            });
                          final topNewJobs = newJobs.take(10).toList();

                          return NewJobsSection(
                            jobs: topNewJobs,
                            favoriteMap: favoriteMap,
                            onJobTap: (job) => _openJobDetail(context, job),
                            onFavoriteToggle: (jobId, isFav) => _toggleFavorite(context, jobId, isFav),
                          );
                        },
                      ),
                      Consumer<JobProvider>(
                        builder: (context, jobProvider3, _) {
                          return Consumer<FavoriteProvider>(
                            builder: (context, favoriteProvider, _) {
                              final favoriteMap = favoriteProvider.favoriteJobIds.fold<Map<String, bool>>(
                                {},
                                (map, jobId) => map..[jobId] = true,
                              );
                              final allJobsForUpcoming = jobProvider3.normalJobs.isNotEmpty
                                  ? jobProvider3.normalJobs
                                  : jobProvider3.urgentJobs;
                              final upcomingJobs = List<Job>.from(allJobsForUpcoming)..sort((a, b) {
                                  final aTime = a.createdAt.millisecondsSinceEpoch;
                                  final bTime = b.createdAt.millisecondsSinceEpoch;
                                  return bTime.compareTo(aTime);
                                });
                              final topUpcomingJobs = upcomingJobs.take(3).toList();

                              return UpcomingShopsSection(
                                jobs: topUpcomingJobs,
                                favoriteMap: favoriteMap,
                                onJobTap: (job) => _openJobDetail(context, job),
                                onFavoriteToggle: (jobId, isFav) => _toggleFavorite(context, jobId, isFav),
                              );
                            },
                          );
                        },
                      ),
                      Consumer<FavoriteProvider>(
                        builder: (context, favoriteProvider, _) {
                          final favoriteMap = favoriteProvider.favoriteJobIds.fold<Map<String, bool>>(
                            {},
                            (map, jobId) => map..[jobId] = true,
                          );
                          return NormalJobsSection(
                            jobs: jobProvider.normalJobs,
                            favoriteMap: favoriteMap,
                            onJobTap: (job) => _openJobDetail(context, job),
                            onFavoriteToggle: (jobId, isFav) => _toggleFavorite(context, jobId, isFav),
                          );
                        },
                      ),
                      const CustomerServiceSection(),
                      SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
