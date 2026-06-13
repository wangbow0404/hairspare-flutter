import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../models/job.dart';
import '../../services/favorite_service.dart';
import 'job_detail_screen.dart';
/// Next.js와 동일한 찜 화면


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
    setState(() {
      _isLoading = true;
    });
    try {
      final favorites = await _favoriteService.getFavorites();
      setState(() {
        _favoriteJobs = favorites;
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailScreen(jobId: job.id),
      ),
    );
  }

  String _formatAmount(int amount) {
    return '₩${NumberFormat('#,###').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: SpareSubpageAppBar(
          title: '찜한 공고',
          showBackButton: canPop,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '찜한 공고',
        showBackButton: canPop,
      ),
      body: _favoriteJobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64, // w-16
                    height: 64, // h-16
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundGray,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    ),
                    child: IconMapper.icon('heart', size: 32, color: AppTheme.textTertiary) ??
                        const Icon(Icons.favorite_border, size: 32, color: AppTheme.textTertiary),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    '찜한 공고가 없습니다',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      '공고 둘러보기 →',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: AppTheme.spacing(AppTheme.spacing4),
              itemCount: _favoriteJobs.length,
              itemBuilder: (context, index) {
                final job = _favoriteJobs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
                  child: GestureDetector(
                    onTap: () => _handleJobTap(job),
                    child: Container(
                      padding: AppTheme.spacing(AppTheme.spacing4),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundWhite,
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.borderGray),
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: Stack(
                        children: [
                          // 찜 버튼 - 우측 상단
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _handleRemoveFavorite(job.id),
                                borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                child: Container(
                                  padding: AppTheme.spacing(AppTheme.spacing2),
                                  child: IconMapper.icon(
                                    'heart',
                                    size: 20,
                                    color: AppTheme.urgentRed,
                                  ) ??
                                      const Icon(
                                        Icons.favorite,
                                        size: 20,
                                        color: AppTheme.urgentRed,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          // 메인 콘텐츠
                          Padding(
                            padding: const EdgeInsets.only(right: 48), // 찜 버튼 공간
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 급구 태그
                                if (job.isUrgent) ...[
                                  Container(
                                    padding: AppTheme.spacingSymmetric(
                                      horizontal: AppTheme.spacing2,
                                      vertical: AppTheme.spacing1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.urgentRed,
                                      borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '🚀',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: AppTheme.spacing1),
                                        Text(
                                          '급구',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacing2),
                                ],
                                // 미용실 이름
                                Text(
                                  job.shopName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing2),
                                // 지역 및 날짜/시간
                                Text(
                                  job.regionId,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing1),
                                Text(
                                  '${job.date} ${job.time}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                // 급구일 경우 카운트다운
                                if (job.isUrgent && job.countdown != null) ...[
                                  const SizedBox(height: AppTheme.spacing2),
                                  Text(
                                    '${(job.countdown! / 86400).floor()}일 남음',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 14,
                                      color: AppTheme.urgentRed,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: AppTheme.spacing2),
                                // 금액 및 예약금
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '금액: ${_formatAmount(job.amount)}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Container(
                                      padding: AppTheme.spacingSymmetric(
                                        horizontal: AppTheme.spacing2,
                                        vertical: AppTheme.spacing1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.yellow400,
                                        borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                                      ),
                                      child: Text(
                                        '${job.energy}개',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppTheme.spacing1),
                                // 필요 인원
                                Text(
                                  '필요 인원: ${job.requiredCount}명',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
