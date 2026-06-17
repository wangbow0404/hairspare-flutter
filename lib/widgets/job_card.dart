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
    return '${NumberFormat('#,###').format(amount)}원';
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

  String _formatDateLine(Job job) {
    final parsed = DateTime.tryParse(job.date);
    final day = parsed == null
        ? job.date
        : '${parsed.month}.${parsed.day} (${_weekdayKo(parsed.weekday)})';
    final end = job.endTime?.trim();
    final time = end == null || end.isEmpty ? job.time : '${job.time}~$end';
    return '$day · $time';
  }

  String _weekdayKo(int weekday) {
    const labels = ['월', '화', '수', '목', '금', '토', '일'];
    if (weekday < 1 || weekday > 7) return '';
    return labels[weekday - 1];
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
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Stack(
              children: [
                if (onFavoriteToggle != null)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      onPressed: onFavoriteToggle,
                      icon:
                          IconMapper.icon(
                            'heart',
                            size: 21,
                            color: isFavorite
                                ? AppTheme.urgentRed
                                : AppTheme.textTertiary,
                          ) ??
                          Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border_rounded,
                            size: 21,
                            color: isFavorite
                                ? AppTheme.urgentRed
                                : AppTheme.textTertiary,
                          ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    right: onFavoriteToggle != null ? 36 : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _JobVisualMark(
                        shopName: job.shopName,
                        isUrgent: isUrgentJob,
                      ),
                      const SizedBox(width: AppTheme.spacing3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: AppTheme.spacing2,
                              runSpacing: AppTheme.spacing1,
                              children: [
                                if (isUrgentJob)
                                  const UrgentJobBadge(
                                    fontSize: 11,
                                    rocketSize: 12,
                                  ),
                                _JobBadge(
                                  label: timeTag,
                                  foreground: AppTheme.green700,
                                  background: AppTheme.green100,
                                ),
                                _JobBadge(
                                  label: isShortTermJob ? '오늘' : '예약',
                                  foreground: isShortTermJob
                                      ? AppTheme.purple700
                                      : AppTheme.textGray700,
                                  background: isShortTermJob
                                      ? AppTheme.purple100
                                      : AppTheme.backgroundGray,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacing2),
                            Text(
                              job.shopName,
                              style: HomeTextStyles.homeCardTitle.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (job.title.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                job.title,
                                style: HomeTextStyles.homeCardMeta.copyWith(
                                  color: AppTheme.textGray700,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: AppTheme.spacing2),
                            _JobMetaLine(
                              icon: Icons.schedule_rounded,
                              text: _formatDateLine(job),
                            ),
                            if (isUrgentJob && job.countdown != null) ...[
                              const SizedBox(height: AppTheme.spacing1),
                              _JobMetaLine(
                                icon: Icons.timer_outlined,
                                text: _formatCountdown(job.countdown!),
                                color: AppTheme.urgentRed,
                              ),
                            ],
                            const SizedBox(height: AppTheme.spacing3),
                            Wrap(
                              spacing: AppTheme.spacing2,
                              runSpacing: AppTheme.spacing2,
                              children: [
                                _JobInfoPill(
                                  icon: Icons.payments_outlined,
                                  label: _formatAmount(job.amount),
                                  isPrimary: true,
                                ),
                                _JobInfoPill(
                                  icon: Icons.people_alt_outlined,
                                  label: '${job.requiredCount}명',
                                ),
                                _JobInfoPill(
                                  icon: Icons.bolt_outlined,
                                  label: '에너지 ${job.energy}',
                                ),
                              ],
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

class _JobVisualMark extends StatelessWidget {
  const _JobVisualMark({required this.shopName, required this.isUrgent});

  final String shopName;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    final initial = shopName.trim().isEmpty ? 'H' : shopName.trim()[0];
    return Container(
      width: 68,
      height: 68,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isUrgent ? AppTheme.red50 : AppTheme.backgroundGray,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(
          color: isUrgent
              ? AppTheme.urgentRed.withValues(alpha: 0.22)
              : AppTheme.borderGray,
        ),
      ),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: isUrgent ? AppTheme.urgentRed : AppTheme.stitchPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _JobBadge extends StatelessWidget {
  const _JobBadge({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: HomeTextStyles.homeCardTag.copyWith(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _JobMetaLine extends StatelessWidget {
  const _JobMetaLine({
    required this.icon,
    required this.text,
    this.color = AppTheme.textSecondary,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppTheme.spacing1),
        Expanded(
          child: Text(
            text,
            style: HomeTextStyles.homeCardMeta.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _JobInfoPill extends StatelessWidget {
  const _JobInfoPill({
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final foreground = isPrimary
        ? AppTheme.stitchPrimaryContainer
        : AppTheme.textGray700;
    final background = isPrimary ? AppTheme.primaryPurpleLight : AppTheme.backgroundGray;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
        border: Border.all(
          color: isPrimary
              ? AppTheme.stitchPrimaryContainer.withValues(alpha: 0.18)
              : AppTheme.borderGray,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 3),
          Text(
            label,
            style: HomeTextStyles.homeCardTag.copyWith(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
