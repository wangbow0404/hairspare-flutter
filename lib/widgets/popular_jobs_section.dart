import 'package:flutter/material.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import '../theme/home_layout_metrics.dart';
import 'stitch/stitch_compact_job_card.dart';
import 'stitch/stitch_section_header.dart';

/// 인기 공고 섹션 (가로 스크롤, 무한 스크롤).
///
/// 자동 스크롤(jumpTo 타이머)은 push 전환 ANR 방지를 위해 비활성화.
class PopularJobsSection extends StatefulWidget {
  final List<Job> jobs;
  final Function(Job)? onJobTap;
  final Function(String, bool)? onFavoriteToggle;
  final Map<String, bool> favoriteMap;
  final VoidCallback? onViewAll;

  const PopularJobsSection({
    super.key,
    required this.jobs,
    this.onJobTap,
    this.onFavoriteToggle,
    required this.favoriteMap,
    this.onViewAll,
  });

  @override
  State<PopularJobsSection> createState() => _PopularJobsSectionState();
}

class _PopularJobsSectionState extends State<PopularJobsSection> {
  final ScrollController _scrollController = ScrollController();

  static const double _cardWidth = HomeLayoutMetrics.horizontalCardWidth;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.jobs.isEmpty) {
      return const SizedBox.shrink();
    }

    // 무한 스크롤처럼 보이게 하려고 3번 반복하는데, 실제 인기 공고가 적으면
    // 같은 공고가 바로 옆에 또 나와서 중복처럼 보임 — 3개 이상일 때만 반복.
    final repeatedJobs = widget.jobs.length >= 3
        ? [...widget.jobs, ...widget.jobs, ...widget.jobs]
        : widget.jobs;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
            child: StitchSectionHeader(
              title: '인기 공고',
              subtitle: '지금 가장 많이 찾는 공고예요',
              onViewAll: widget.onViewAll,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          SizedBox(
            height: HomeLayoutMetrics.thumbnailCarouselHeight,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                left: AppTheme.spacing4 + MediaQuery.of(context).padding.left,
                right: AppTheme.spacing4 + MediaQuery.of(context).padding.right,
              ),
              itemCount: repeatedJobs.length,
              itemBuilder: (context, index) {
                final job = repeatedJobs[index];
                final isFavorite = widget.favoriteMap[job.id] ?? false;
                return Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spacing4),
                  child: StitchCompactJobCard(
                    job: job,
                    isFavorite: isFavorite,
                    width: _cardWidth,
                    height: HomeLayoutMetrics.thumbnailCarouselHeight,
                    showThumbnail: true,
                    badgeLabel: job.isUrgent ? '급구' : '인기',
                    badgeColor: job.isUrgent
                        ? AppTheme.urgentRed
                        : AppTheme.stitchPrimary,
                    onTap: () => widget.onJobTap?.call(job),
                    onFavoriteToggle: () =>
                        widget.onFavoriteToggle?.call(job.id, isFavorite),
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
