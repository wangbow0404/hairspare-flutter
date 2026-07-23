import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import '../theme/hairspare_colors.dart';
import '../utils/icon_mapper.dart';
import '../utils/region_helper.dart';
import 'common/job_thumbnail.dart';

/// 하이패스 공고 섹션 (다크 배경 + 화이트 카드, 한 줄 가로 스크롤)
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

  static const Color _textMuted = HairSpareColors.textSecondary;

  String _formatAmount(int amount) => NumberFormat('#,###').format(amount);

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

  String _getDayTag(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(date.year, date.month, date.day);
      final diff = target.difference(today).inDays;
      if (diff == 0) return '오늘';
      if (diff == 1) return '내일';
      if (diff < 0 || diff > 6) {
        return DateFormat('M월 d일', 'ko_KR').format(date);
      }
      const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      return '이번주 ${weekdays[date.weekday - 1]}';
    } catch (e) {
      return '';
    }
  }

  int? _toMinutes(String? hhmm) {
    if (hhmm == null || !hhmm.contains(':')) return null;
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0');
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  String _getDurationLabel(String? time, String? endTime) {
    final start = _toMinutes(time);
    var end = _toMinutes(endTime);
    if (start == null || end == null) return '';
    if (end <= start) end += 24 * 60;
    final hours = (end - start) / 60;
    final rounded = hours.roundToDouble();
    final label =
        (hours - rounded).abs() < 0.01 ? '${rounded.toInt()}' : '$hours';
    return ' ($label시간)';
  }

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) return const SizedBox.shrink();
    final displayJobs = jobs;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppTheme.spacing2),
      decoration: BoxDecoration(
        color: HairSpareColors.brandPrimarySoft,
        border: Border(
          top: BorderSide(color: HairSpareColors.border),
          bottom: BorderSide(color: HairSpareColors.border),
        ),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/brand/hipass_mark.png',
                width: 28,
                height: 28,
              ),
              const SizedBox(width: AppTheme.spacing2),
              const Text(
                '하이패스 프리미엄 공고',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: HairSpareColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing1),
          const Text(
            '지금 가장 빠르게 매칭되는 공고',
            style: TextStyle(fontSize: 14, color: _textMuted),
          ),
          const SizedBox(height: AppTheme.spacing4),
          SizedBox(
            height: 268,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: displayJobs.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppTheme.spacing3),
              itemBuilder: (context, index) {
                final job = displayJobs[index];
                final isFavorite = favoriteMap[job.id] ?? false;
                return _UpcomingCard(
                  job: job,
                  isFavorite: isFavorite,
                  timeTag: _getTimeTag(job.time),
                  dayTag: _getDayTag(job.date),
                  durationLabel: _getDurationLabel(job.time, job.endTime),
                  amount: _formatAmount(job.amount),
                  onTap: () => onJobTap?.call(job),
                  onFavoriteToggle: () =>
                      onFavoriteToggle?.call(job.id, isFavorite),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({
    required this.job,
    required this.isFavorite,
    required this.timeTag,
    required this.dayTag,
    required this.durationLabel,
    required this.amount,
    this.onTap,
    this.onFavoriteToggle,
  });

  final Job job;
  final bool isFavorite;
  final String timeTag;
  final String dayTag;
  final String durationLabel;
  final String amount;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final region = RegionHelper.getRegionName(job.regionId).trim();

    return SizedBox(
      width: 190,
      child: Material(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: HairSpareColors.brandPrimary.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    JobThumbnail(
                      job: job,
                      width: 190,
                      height: 116,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.radiusLg),
                        topRight: Radius.circular(AppTheme.radiusLg),
                      ),
                    ),
                    Positioned(
                      left: AppTheme.spacing2,
                      bottom: AppTheme.spacing2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt,
                              size: 12,
                              color: HairSpareColors.brandPrimary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'HIPASS',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: HairSpareColors.brandPrimary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: AppTheme.spacing1,
                      right: AppTheme.spacing1,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.32),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: onFavoriteToggle,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: IconMapper.icon(
                                  'heart',
                                  size: 16,
                                  color: isFavorite
                                      ? HairSpareColors.statusUrgent
                                      : Colors.white,
                                ) ??
                                Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 16,
                                  color: isFavorite
                                      ? HairSpareColors.statusUrgent
                                      : Colors.white,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        job.shopName.isEmpty ? '매장명' : job.shopName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (region.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: AppTheme.textTertiary,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                region,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 13,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              '$dayTag $timeTag$durationLabel',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      const Divider(height: 1, color: AppTheme.borderGray),
                      const SizedBox(height: AppTheme.spacing2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '일급',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '$amount원',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: HairSpareColors.brandPrimary,
                            ),
                          ),
                        ],
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
