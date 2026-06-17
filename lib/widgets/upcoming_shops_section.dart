import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';
import 'common/job_thumbnail.dart';

/// 오픈 예정 매장 섹션 (다크 테마, 한 줄 가로 스크롤)
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

  static const Color _textMuted = Color(0xFFD1D5DB); // gray-300

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

  String _getOpenDate(DateTime createdAt) {
    final openDate = createdAt.add(const Duration(hours: 24));
    return DateFormat('M월 d일', 'ko_KR').format(openDate);
  }

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
    final displayJobs = _ensureThreeItems(jobs);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F2937), Color(0xFF111827)],
        ),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오픈 예정 매장',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.spacing1),
          const Text(
            '기대되는 매장을 미리 찜해보세요',
            style: TextStyle(fontSize: 14, color: _textMuted),
          ),
          const SizedBox(height: AppTheme.spacing4),
          SizedBox(
            height: 230,
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
                  openDate: _getOpenDate(job.createdAt),
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
    required this.openDate,
    required this.amount,
    this.onTap,
    this.onFavoriteToggle,
  });

  final Job job;
  final bool isFavorite;
  final String timeTag;
  final String openDate;
  final String amount;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  static const Color _surfaceDark = Color(0xFF374151);
  static const Color _textMuted = Color(0xFFD1D5DB);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Material(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  JobThumbnail(
                    job: job,
                    width: 170,
                    height: 104,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusLg),
                      topRight: Radius.circular(AppTheme.radiusLg),
                    ),
                  ),
                  Positioned(
                    top: AppTheme.spacing2,
                    left: AppTheme.spacing2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.stitchHeroGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.stitchPrimary.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text(
                        'OPEN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
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
                                    ? AppTheme.urgentRed
                                    : Colors.white,
                              ) ??
                              Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 16,
                                color: isFavorite
                                    ? AppTheme.urgentRed
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
                    Row(
                      children: [
                        _Tag(label: timeTag, color: AppTheme.stitchPrimary),
                        const SizedBox(width: 4),
                        _Tag(
                          label: '장기',
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job.shopName.isEmpty ? '매장명' : job.shopName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '오픈 $openDate',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD8B4FE), // purple-300
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$amount원~',
                      style: const TextStyle(fontSize: 11, color: _textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
