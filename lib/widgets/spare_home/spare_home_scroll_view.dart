import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/favorite_provider.dart';
import '../../providers/job_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_grid.dart';
import '../../utils/app_screen_insets.dart';
import 'spare_home_app_bar.dart';
import 'spare_home_job_sections.dart';
import 'spare_home_promo_banner.dart';
import 'spare_home_quick_menu.dart';

/// 스페어·디자이너 홈 본문 (a안).
class SpareHomeScrollView extends StatefulWidget {
  const SpareHomeScrollView({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<SpareHomeScrollView> createState() => _SpareHomeScrollViewState();
}

class _SpareHomeScrollViewState extends State<SpareHomeScrollView> {
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        AppScreenInsets.pinnedTopBarSliver(
          context: context,
          child: SpareHomeAppBarRow(scrollController: widget.scrollController),
        ),
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.spacing3),
              const SpareHomePromoBanner(),
              const SizedBox(height: AppTheme.spacing3),
              CategoryGrid(
                padding: const EdgeInsets.only(
                  left: AppTheme.spacing4,
                  right: AppTheme.spacing4,
                  bottom: AppTheme.spacing2,
                ),
                crossAxisCount: 6,
                wrapInCard: false,
                categories: SpareHomeQuickMenu.buildCategories(context),
              ),
              const SizedBox(height: AppTheme.spacing3),
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
