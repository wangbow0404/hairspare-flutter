import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/job_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/stitch/stitch_hero_banner.dart';
import 'spare_home_quick_menu.dart';
import '../../utils/app_screen_insets.dart';
import 'spare_home_app_bar.dart';
import 'spare_home_job_sections.dart';

/// 스페어·디자이너 홈 본문(헤더·배너·공고 섹션).
class SpareHomeScrollView extends StatelessWidget {
  const SpareHomeScrollView({super.key, required this.scrollController});

  final ScrollController scrollController;

  static Future<void> _toggleFavorite(
    BuildContext context,
    String jobId,
    bool isFavorite,
  ) async {
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);
    final success = await favoriteProvider.toggleFavorite(jobId);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            favoriteProvider.error ?? '찜 상태 업데이트에 실패했습니다.',
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  static void _onBannerTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.push(AppRoutes.spareHomeJobsPath(filter: 'urgent'));
        break;
      case 1:
        context.push(AppRoutes.spareHomeEnergy);
        break;
      case 2:
        context.push(AppRoutes.spareHomeEducation);
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
        AppScreenInsets.pinnedTopBarSliver(
          context: context,
          child: SpareHomeAppBarRow(scrollController: scrollController),
        ),
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StitchHeroBanner(
                height: 240,
                onCtaTap: (index) => _onBannerTap(context, index),
              ),
              const SizedBox(height: AppTheme.spacing4),
              CategoryGrid(
                padding: const EdgeInsets.only(
                  top: 0,
                  bottom: AppTheme.spacing2,
                ),
                categories: SpareHomeQuickMenu.buildCategories(context),
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

                  return SpareHomeJobSections(
                    onToggleFavorite: _toggleFavorite,
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
