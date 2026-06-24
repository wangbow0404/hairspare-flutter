import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../models/job.dart';
import '../../providers/favorite_provider.dart';
import '../../services/favorite_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/job_popularity.dart';
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
  List<Job> _favoriteJobs = [];
  bool _isLoading = true;
  final FavoriteService _favoriteService = FavoriteService();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await _favoriteService.getFavorites();
      if (mounted) {
        setState(() {
          _favoriteJobs = favorites;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        final errorMessage = error.toString().contains('connection errored') ||
                error.toString().contains('XMLHttpRequest')
            ? '서버에 연결할 수 없습니다. Next.js 서버가 실행 중인지 확인해주세요.'
            : '찜 목록을 불러오는 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.urgentRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _handleRemoveFavorite(String jobId) async {
    try {
      await _favoriteService.removeFavorite(jobId);
      setState(() {
        _favoriteJobs.removeWhere((job) => job.id == jobId);
      });
      if (mounted) {
        Provider.of<FavoriteProvider>(context, listen: false).loadFavorites();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('찜이 삭제되었습니다.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('찜 삭제 중 오류가 발생했습니다: $error')),
        );
      }
    }
  }

  void _handleJobTap(Job job) {
    context.push(AppRoutes.spareFavoritesJobDetail(job.id));
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '찜한 공고',
        showBackButton: canPop,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteJobs.isEmpty
              ? StitchEmptyState(
                  message: '찜한 공고가 없습니다',
                  iconName: 'heart',
                  actionLabel: '공고 둘러보기',
                  onAction: () => Navigator.maybePop(context),
                )
              : ListView.builder(
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  itemCount: _favoriteJobs.length,
                  itemBuilder: (context, index) {
                    final job = _favoriteJobs[index];
                    final popularIds =
                        JobPopularity.popularJobIds(_favoriteJobs);
                    return StitchListJobCard(
                      job: job,
                      isFavorite: true,
                      showPopularBadge: JobPopularity.showsPopularBadge(
                        job,
                        popularIds,
                      ),
                      onTap: () => _handleJobTap(job),
                      onFavoriteToggle: () => _handleRemoveFavorite(job.id),
                    );
                  },
                ),
    );
  }
}
