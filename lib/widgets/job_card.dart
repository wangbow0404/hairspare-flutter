import 'package:flutter/material.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart'; // IconMapper import
import 'package:intl/intl.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final bool isUrgent;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.isUrgent = false,
  });

  String _formatAmount(int amount) {
    return '₩${NumberFormat('#,###').format(amount)}';
  }

  String _formatCountdown(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}시간 ${minutes}분 남음';
    } else {
      return '${minutes}분 남음';
    }
  }

  String _getTimeTag(String timeStr) {
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

  bool _isShortTerm(String date) {
    try {
      final jobDate = DateTime.parse(date);
      final today = DateTime.now();
      final difference = jobDate.difference(today).inDays;
      return difference == 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrgentJob = isUrgent || job.isUrgent;
    final isPremiumUrgent = isUrgentJob && job.isPremium;
    final isShortTermJob = _isShortTerm(job.date);
    final timeTag = _getTimeTag(job.time);

    // 카드 배경색 및 테두리 색상 결정
    Color borderColor;
    Color backgroundColor;
    if (isPremiumUrgent) {
      borderColor = AppTheme.urgentRed; // border-red-500
      backgroundColor = AppTheme.urgentRedLight; // bg-red-50
    } else if (isUrgentJob) {
      borderColor = AppTheme.orange500; // border-orange-500
      backgroundColor = AppTheme.orange50; // bg-orange-50
    } else {
      borderColor = AppTheme.borderGray; // border-gray-200
      backgroundColor = AppTheme.backgroundWhite; // bg-white
    }

    return Container(
      margin: EdgeInsets.only(
        bottom: AppTheme.spacing3, // space-y-3 (mb-3)
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg), // rounded-lg
        border: Border.all(
          color: borderColor,
          width: isUrgentJob ? 2 : 1, // 급구는 border-2, 일반은 border
        ),
        boxShadow: AppTheme.shadowSm, // shadow-sm
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
          child: Padding(
            padding: AppTheme.spacing(AppTheme.spacing4), // p-4
            child: Stack(
              children: [
                // 찜 버튼 - 우측 상단
                if (onFavoriteToggle != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onFavoriteToggle,
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        child: Container(
                          padding: AppTheme.spacing(AppTheme.spacing2), // p-2
                          child: IconMapper.icon(
                            'heart',
                            size: 20,
                            color: isFavorite
                                ? AppTheme.urgentRed // text-red-500 fill-red-500
                                : AppTheme.textTertiary, // text-gray-400
                          ) ??
                              Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 20, // w-5 h-5
                                color: isFavorite
                                    ? AppTheme.urgentRed // text-red-500 fill-red-500
                                    : AppTheme.textTertiary, // text-gray-400
                              ),
                        ),
                      ),
                    ),
                  ),

                // 급구 태그 - 우측 상단 (찜 버튼 왼쪽)
                if (isUrgentJob)
                  Positioned(
                    top: 0,
                    right: 64, // right-16 (찜 버튼 너비 + 간격)
                    child: Container(
                      padding: AppTheme.spacingSymmetric(
                        horizontal: AppTheme.spacing2,
                        vertical: AppTheme.spacing1,
                      ), // px-2 py-1
                      decoration: BoxDecoration(
                        color: AppTheme.urgentRed, // bg-red-500
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusSm), // rounded
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🚀',
                            style: TextStyle(fontSize: 16), // text-base leading-none
                          ),
                          SizedBox(width: AppTheme.spacing1),
                          Text(
                            '급구',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 12, // text-xs
                              fontWeight: FontWeight.w600, // font-semibold
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 메인 콘텐츠
                Padding(
                  padding: EdgeInsets.only(
                    right: onFavoriteToggle != null ? 48 : 0, // pr-12 (찜 버튼 공간)
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이미지 영역
                      Container(
                        width: 80, // w-20
                        height: 80, // h-20
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.green200, // from-green-200
                              AppTheme.blue200, // to-blue-200
                            ],
                          ),
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg), // rounded-lg
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing3), // gap-3

                      // 내용 영역
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 태그들
                            Wrap(
                              spacing: AppTheme.spacing2, // gap-2
                              children: [
                                // 시간 태그
                                Container(
                                  padding: AppTheme.spacingSymmetric(
                                    horizontal: AppTheme.spacing2,
                                    vertical: AppTheme.spacing1,
                                  ), // px-2 py-1
                                  decoration: BoxDecoration(
                                    color: AppTheme.green100, // bg-green-100
                                    borderRadius: AppTheme.borderRadius(AppTheme.radiusSm), // rounded
                                  ),
                                  child: Text(
                                    timeTag,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontSize: 12, // text-xs
                                      color: AppTheme.green700, // text-green-700
                                      fontWeight: FontWeight.w500, // font-medium
                                    ),
                                  ),
                                ),
                                // 단기/장기 태그
                                Container(
                                  padding: AppTheme.spacingSymmetric(
                                    horizontal: AppTheme.spacing2,
                                    vertical: AppTheme.spacing1,
                                  ), // px-2 py-1
                                  decoration: BoxDecoration(
                                    color: isShortTermJob
                                        ? AppTheme.purple100 // bg-purple-100
                                        : AppTheme.backgroundGray, // bg-gray-100
                                    borderRadius: AppTheme.borderRadius(AppTheme.radiusSm), // rounded
                                  ),
                                  child: Text(
                                    isShortTermJob ? '단기' : '장기',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontSize: 12, // text-xs
                                      color: isShortTermJob
                                          ? AppTheme.purple700 // text-purple-700
                                          : AppTheme.textGray700, // text-gray-700
                                      fontWeight: FontWeight.w500, // font-medium
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppTheme.spacing2), // mb-2

                            // 미용실 이름 (Next.js에서는 h4로 표시)
                            Text(
                              job.shopName,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 14, // text-sm
                                fontWeight: FontWeight.w600, // font-semibold
                                color: AppTheme.textPrimary, // text-gray-900
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppTheme.spacing1), // mb-1

                            // 날짜/시간
                            Text(
                              '${job.date} ${job.time}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 12, // text-xs
                                color: AppTheme.textSecondary, // text-gray-600
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing1), // mb-1

                            // 카운트다운 (급구일 때만)
                            if (isUrgentJob && job.countdown != null) ...[
                              Text(
                                _formatCountdown(job.countdown!),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 12, // text-xs
                                  color: AppTheme.urgentRed, // text-red-600
                                  fontWeight: FontWeight.w500, // font-medium
                                ),
                              ),
                              SizedBox(height: AppTheme.spacing1), // mb-1
                            ],

                            // 금액
                            Text(
                              '금액: ${_formatAmount(job.amount)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 12, // text-xs
                                color: AppTheme.textSecondary, // text-gray-600
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing1), // mb-1

                            // 필요 인원
                            Text(
                              '필요 인원: ${job.requiredCount}명',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 12, // text-xs
                                color: AppTheme.textSecondary, // text-gray-600
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing1), // mb-1

                            // 예약금(에너지)
                            Text(
                              '예약금(에너지): ${job.energy}개',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 12, // text-xs
                                color: AppTheme.textSecondary, // text-gray-600
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
