import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';

/// 오픈 예정 매장 섹션 (한 줄 가로 스크롤)
class UpcomingShopsSection extends StatelessWidget {
  final List<Job> jobs;
  final Function(Job)? onJobTap;
  final Function(String, bool)? onFavoriteToggle;
  final Map<String, bool> favoriteMap;

  const UpcomingShopsSection({
    super.key,
    required this.jobs,
    this.onJobTap,
    this.onFavoriteToggle,
    required this.favoriteMap,
  });

  String _formatAmount(int amount) {
    return NumberFormat('#,###').format(amount);
  }

  String _getTimeTag(String? timeStr) {
    if (timeStr == null) return '오후';
    try {
      final hour = int.parse(timeStr.split(':')[0]);
      if (hour >= 6 && hour < 12) return '오전';
      if (hour >= 12 && hour < 18) return '오후';
      if (hour >= 18 && hour < 22) return '저녁';
      return '야간';
    } catch (e) {
      return '오후';
    }
  }

  String _getOpenDate(DateTime createdAt) {
    // 오픈 예정일 계산 (등록일로부터 24시간 후)
    final openDate = createdAt.add(const Duration(hours: 24));
    return DateFormat('M월 d일', 'ko_KR').format(openDate);
  }

  /// 3개 확인용 더미 Job 생성
  List<Job> _ensureThreeItems(List<Job> jobs) {
    if (jobs.length >= 3) return jobs.take(3).toList();
    final result = List<Job>.from(jobs);
    final now = DateTime.now();
    while (result.length < 3) {
      result.add(Job(
        id: 'dummy-upcoming-${result.length}',
        title: '오픈 예정 매장 ${result.length + 1}',
        shopName: '헤어스튜디오 ${String.fromCharCode(65 + result.length)}',
        date: now.toIso8601String().split('T')[0],
        time: '10:00',
        amount: 80000,
        energy: 80,
        requiredCount: 1,
        regionId: 'region-1',
        isUrgent: false,
        isPremium: false,
        createdAt: now.subtract(Duration(days: result.length)),
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // 최대 3개 표시 (부족하면 더미로 채움)
    final displayJobs = _ensureThreeItems(jobs);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1F2937), // gray-800
            const Color(0xFF111827), // gray-900
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Text(
            '오픈 예정 매장',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppTheme.spacing2),
          Text(
            '기대되는 매장을 찜해보세요!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: const Color(0xFFD1D5DB), // gray-300
            ),
          ),
          SizedBox(height: AppTheme.spacing3),
          // 한 줄 가로 스크롤 (고정 폭/높이, Expanded 사용 없음)
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: displayJobs.length,
              separatorBuilder: (_, __) => SizedBox(width: AppTheme.spacing2),
              itemBuilder: (context, index) {
                final job = displayJobs[index];
                final isFavorite = favoriteMap[job.id] ?? false;
                final timeTag = _getTimeTag(job.time);
                final openDateStr = _getOpenDate(job.createdAt);

                return SizedBox(
                  width: 160,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onJobTap?.call(job),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 이미지 영역 (고정 높이)
                              Container(
                                width: 160,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primaryPink.withOpacity(0.8),
                                      AppTheme.primaryPurple.withOpacity(0.8),
                                      AppTheme.primaryBlue.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(AppTheme.radiusLg),
                                    topRight: Radius.circular(AppTheme.radiusLg),
                                  ),
                                ),
                              ),
                              // 내용 영역 (고정 높이)
                              Container(
                                width: 160,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF374151),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(AppTheme.radiusLg),
                                    bottomRight: Radius.circular(AppTheme.radiusLg),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing1,
                                  vertical: AppTheme.spacing1 / 2,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryPink,
                                            borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                                          ),
                                          child: Text(
                                            timeTag,
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                                          ),
                                          child: Text(
                                            '장기',
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      job.shopName ?? '매장명',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '오픈: $openDateStr',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 8,
                                        color: AppTheme.primaryPink.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_formatAmount(job.amount ?? 0)}원~',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 8,
                                        color: const Color(0xFFD1D5DB),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPink,
                                borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                              ),
                              child: Text(
                                'AD',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontSize: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Material(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                              child: InkWell(
                                onTap: () {
                                  onFavoriteToggle?.call(job.id, isFavorite);
                                },
                                borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: IconMapper.icon(
                                      'heart',
                                      size: 12,
                                      color: isFavorite
                                          ? AppTheme.urgentRed
                                          : Colors.white,
                                    ) ??
                                        Icon(
                                          isFavorite ? Icons.favorite : Icons.favorite_border,
                                          size: 12,
                                          color: isFavorite
                                              ? AppTheme.urgentRed
                                              : Colors.white,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
