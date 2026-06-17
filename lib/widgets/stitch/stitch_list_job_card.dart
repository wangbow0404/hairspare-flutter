import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/job.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/region_helper.dart';
import '../common/job_thumbnail.dart';

/// Stitch 세로 리스트용 공고 카드.
/// 좌측 80x80 사진 + 우측 배지/매장명/일정/일급 강조. (일반·카테고리 리스트 공용)
class StitchListJobCard extends StatelessWidget {
  const StitchListJobCard({
    super.key,
    required this.job,
    required this.isFavorite,
    this.showPopularBadge = false,
    this.onTap,
    this.onFavoriteToggle,
    this.margin,
  });

  final Job job;
  final bool isFavorite;
  final bool showPopularBadge;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final EdgeInsetsGeometry? margin;

  String _formatPay(int amount) => '${NumberFormat('#,###').format(amount)}원';

  String _formatScheduleLine(Job job) {
    final parsed = DateTime.tryParse(job.date);
    final dayLabel = parsed == null ? job.date : _relativeDayLabel(parsed);
    final end = job.endTime?.trim();
    final time = end == null || end.isEmpty ? job.time : '${job.time} - $end';
    final region = RegionHelper.getRegionName(job.regionId).trim();
    if (region.isNotEmpty && region != job.regionId) {
      return '$region • $dayLabel, $time';
    }
    return '$dayLabel, $time';
  }

  String _relativeDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return '오늘';
    if (diff == 1) return '내일';
    return '${date.month}.${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Material(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: AppTheme.borderGray),
              boxShadow: AppTheme.stitchSoftShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JobThumbnail(
                    job: job,
                    width: 80,
                    height: 80,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  const SizedBox(width: AppTheme.spacing3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (job.isUrgent) ...[
                          _buildBadge(
                            '급구',
                            AppTheme.urgentRed.withValues(alpha: 0.1),
                            AppTheme.urgentRed,
                          ),
                          const SizedBox(height: AppTheme.spacing2),
                        ] else if (showPopularBadge) ...[
                          _buildBadge(
                            '인기',
                            AppTheme.stitchPrimary.withValues(alpha: 0.1),
                            AppTheme.stitchPrimary,
                          ),
                          const SizedBox(height: AppTheme.spacing2),
                        ],
                        Text(
                          job.shopName.isEmpty ? '매장명 없음' : job.shopName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.stitchTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.spacing1),
                        Text(
                          _formatScheduleLine(job),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.stitchTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.spacing2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              '일급 ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.stitchTextSecondary,
                              ),
                            ),
                            Text(
                              _formatPay(job.amount),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.stitchTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onFavoriteToggle != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: onFavoriteToggle,
                      icon: IconMapper.icon(
                            'heart',
                            size: 22,
                            color: isFavorite
                                ? AppTheme.urgentRed
                                : AppTheme.outline,
                          ) ??
                          Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 22,
                            color: isFavorite
                                ? AppTheme.urgentRed
                                : AppTheme.outline,
                          ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
