import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';

/// 오픈 예정 매장 섹션 (4개 그리드, 어두운 배경)
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

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return const SizedBox.shrink();
    }

    // 최대 4개만 표시
    final displayJobs = jobs.take(4).toList();

    return Container(
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
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
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
          SizedBox(height: AppTheme.spacing4),
          // 4개 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppTheme.spacing3,
              mainAxisSpacing: AppTheme.spacing3,
              childAspectRatio: 0.75, // 카드 비율 조정
            ),
            itemCount: displayJobs.length,
            itemBuilder: (context, index) {
              final job = displayJobs[index];
              final isFavorite = favoriteMap[job.id] ?? false;
              final timeTag = _getTimeTag(job.time);
              final openDateStr = _getOpenDate(job.createdAt);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onJobTap?.call(job),
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 이미지 영역 (그라데이션)
                          Container(
                            height: 112, // h-28
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
                          // 내용 영역
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF374151), // gray-700
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(AppTheme.radiusLg),
                                  bottomRight: Radius.circular(AppTheme.radiusLg),
                                ),
                              ),
                              padding: EdgeInsets.all(AppTheme.spacing2 + AppTheme.spacing1 / 2), // p-2.5
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 태그 영역
                                  Wrap(
                                    spacing: AppTheme.spacing1,
                                    runSpacing: AppTheme.spacing1,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppTheme.spacing1 + AppTheme.spacing1 / 2, // px-1.5
                                          vertical: AppTheme.spacing1 / 2, // py-0.5
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryPink,
                                          borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                                        ),
                                        child: Text(
                                          timeTag,
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppTheme.spacing1 + AppTheme.spacing1 / 2,
                                          vertical: AppTheme.spacing1 / 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                                        ),
                                        child: Text(
                                          '장기',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppTheme.spacing1 + AppTheme.spacing1 / 2), // mb-1.5
                                  // 매장명
                                  Text(
                                    job.shopName ?? '매장명 없음',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: AppTheme.spacing1), // mb-1
                                  // 오픈 예정일
                                  Text(
                                    '오픈: $openDateStr',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      color: AppTheme.primaryPink.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: AppTheme.spacing1), // mb-1
                                  // 금액
                                  Text(
                                    '${_formatAmount(job.amount ?? 0)}원 상당...',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      color: const Color(0xFFD1D5DB), // gray-300
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // AD 배지 - 좌측 상단
                      Positioned(
                        top: AppTheme.spacing1 + AppTheme.spacing1 / 2, // top-1.5
                        left: AppTheme.spacing1 + AppTheme.spacing1 / 2, // left-1.5
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing1 + AppTheme.spacing1 / 2,
                            vertical: AppTheme.spacing1 / 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPink,
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                          ),
                          child: Text(
                            'AD',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // 찜 버튼 - 우측 상단
                      Positioned(
                        top: AppTheme.spacing1 + AppTheme.spacing1 / 2,
                        right: AppTheme.spacing1 + AppTheme.spacing1 / 2,
                        child: Material(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                          child: InkWell(
                            onTap: () {
                              onFavoriteToggle?.call(job.id, isFavorite);
                            },
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                            child: Container(
                              width: 24, // w-6
                              height: 24, // h-6
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: IconMapper.icon(
                                  'heart',
                                  size: 14,
                                  color: isFavorite
                                      ? AppTheme.urgentRed
                                      : Colors.white,
                                ) ??
                                    Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      size: 14,
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
              );
            },
          ),
        ],
      ),
    );
  }
}
