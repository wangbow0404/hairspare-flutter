import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../models/job.dart';
import '../../providers/favorite_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/job_popularity.dart';
import '../../widgets/common/shimmer_box.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../widgets/stitch/stitch_list_job_card.dart';

/// 찜한 공고 목록 — Stitch ListTemplate.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FavoriteProvider>().loadFavorites();
    });
  }

  Future<void> _handleRemoveFavorite(
    FavoriteProvider provider,
    String jobId,
  ) async {
    final removed = await provider.removeFavorite(jobId);
    if (!mounted || !removed) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('찜을 삭제했어요'),
        action: SnackBarAction(
          label: '실행취소',
          onPressed: () => provider.addFavorite(jobId),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleJobTap(Job job) {
    context.push(AppRoutes.spareFavoritesJobDetail(job.id));
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(title: '찜한 공고', showBackButton: canPop),
      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, _) {
          if (favoriteProvider.isLoading &&
              favoriteProvider.favorites.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppTheme.spacing4),
              child: Column(
                children: [
                  JobCardSkeleton(),
                  JobCardSkeleton(),
                  JobCardSkeleton(),
                ],
              ),
            );
          }

          final favoriteJobs = favoriteProvider.favorites;
          if (favoriteJobs.isEmpty) {
            return StitchEmptyState(
              message: '찜한 공고가 없습니다',
              iconName: 'heart',
              actionLabel: '공고 둘러보기',
              onAction: () => Navigator.maybePop(context),
            );
          }

          final popularIds = JobPopularity.popularJobIds(favoriteJobs);
          return RefreshIndicator(
            onRefresh: favoriteProvider.loadFavorites,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppTheme.spacing(AppTheme.spacing4),
              itemCount: favoriteJobs.length,
              itemBuilder: (context, index) {
                final job = favoriteJobs[index];
                return StitchListJobCard(
                  job: job,
                  isFavorite: true,
                  showPopularBadge: JobPopularity.showsPopularBadge(
                    job,
                    popularIds,
                  ),
                  onTap: () => _handleJobTap(job),
                  onFavoriteToggle: () =>
                      _handleRemoveFavorite(favoriteProvider, job.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
