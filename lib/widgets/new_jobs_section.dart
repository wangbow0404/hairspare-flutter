import 'package:flutter/material.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import '../theme/home_layout_metrics.dart';
import 'stitch/stitch_compact_job_card.dart';
import 'stitch/stitch_section_header.dart';

/// 신규 공고 섹션 (가로 스크롤, 무한 스크롤).
///
/// 자동 스크롤(jumpTo 타이머)은 push 전환 ANR 방지를 위해 비활성화.
class NewJobsSection extends StatefulWidget {
  final List<Job> jobs;
  final Function(Job)? onJobTap;
  final Function(String, bool)? onFavoriteToggle;
  final Map<String, bool> favoriteMap;
  final VoidCallback? onViewAll;

  const NewJobsSection({
    super.key,
    required this.jobs,
    this.onJobTap,
    this.onFavoriteToggle,
    required this.favoriteMap,
    this.onViewAll,
  });

  @override
  State<NewJobsSection> createState() => _NewJobsSectionState();
}

class _NewJobsSectionState extends State<NewJobsSection> {
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

    final repeatedJobs = [...widget.jobs, ...widget.jobs, ...widget.jobs];

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
            child: StitchSectionHeader(
              title: '신규 공고',
              subtitle: '방금 올라온 따끈한 공고예요',
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
                    badgeLabel: job.isUrgent ? '급구' : 'NEW',
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
