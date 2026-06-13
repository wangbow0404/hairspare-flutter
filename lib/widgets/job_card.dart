import 'package:flutter/material.dart';
import 'package:hairspare/widgets/job/urgent_job_card_theme.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import '../theme/home_text_styles.dart';
import '../utils/icon_mapper.dart';

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
      return '$hours시간 $minutes분 남음';
    } else {
      return '$minutes분 남음';
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
    final isShortTermJob = _isShortTerm(job.date);
    final timeTag = _getTimeTag(job.time);

    return Container(
      margin: const EdgeInsets.only(
        bottom: AppTheme.spacing3, // space-y-3 (mb-3)
      ),
      decoration: UrgentJobCardTheme.cardDecoration(isUrgent: isUrgentJob),
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
                  const Positioned(
                    top: 0,
                    right: 64,
                    child: UrgentJobBadge(fontSize: 12, rocketSize: 16),
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
                      const SizedBox(width: AppTheme.spacing3), // gap-3

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
                                    style: HomeTextStyles.homeCardTag
                                        .copyWith(color: AppTheme.green700),
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
                                    style: HomeTextStyles.homeCardTag.copyWith(
                                      color: isShortTermJob
                                          ? AppTheme.purple700
                                          : AppTheme.textGray700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacing2), // mb-2

                            // 미용실 이름 (Next.js에서는 h4로 표시)
                            Text(
                              job.shopName,
                              style: HomeTextStyles.homeCardTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppTheme.spacing1), // mb-1

                            // 날짜/시간
                            Text(
                              '${job.date} ${job.time}',
                              style: HomeTextStyles.homeCardMeta,
                            ),
                            const SizedBox(height: AppTheme.spacing1), // mb-1

                            // 카운트다운 (급구일 때만)
                            if (isUrgentJob && job.countdown != null) ...[
                              Text(
                                _formatCountdown(job.countdown!),
                                style: HomeTextStyles.homeCardMeta.copyWith(
                                  color: AppTheme.urgentRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing1), // mb-1
                            ],

                            // 금액
                            Text(
                              '금액: ${_formatAmount(job.amount)}',
                              style: HomeTextStyles.homeCardMeta,
                            ),
                            const SizedBox(height: AppTheme.spacing1), // mb-1

                            // 필요 인원
                            Text(
                              '필요 인원: ${job.requiredCount}명',
                              style: HomeTextStyles.homeCardMeta,
                            ),
                            const SizedBox(height: AppTheme.spacing1), // mb-1

                            // 예약금(에너지)
                            Text(
                              '예약금(에너지): ${job.energy}개',
                              style: HomeTextStyles.homeCardMeta,
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
