import 'dart:async';
import 'package:flutter/material.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import '../theme/home_layout_metrics.dart';
import 'stitch/stitch_compact_job_card.dart';
import 'stitch/stitch_section_header.dart';

/// 인기 공고 섹션 (가로 스크롤, 무한 스크롤, 자동 스크롤)
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
  bool _isScrolling = false;
  Timer? _autoScrollTimer;
  double _scrollPosition = 0.0;

  static const double _cardWidth = HomeLayoutMetrics.horizontalCardWidth;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.jobs.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollPosition = 0;
        _scrollController.jumpTo(0);
      }
    });

    _autoScrollTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (timer) {
        if (!_isScrolling && mounted && _scrollController.hasClients) {
          const cardWidth = _cardWidth + AppTheme.spacing4;
          final oneSetWidth = widget.jobs.length * cardWidth;
          final maxScroll = _scrollController.position.maxScrollExtent;
          final currentScroll = _scrollController.position.pixels;

          if (currentScroll >= oneSetWidth - 1) {
            _scrollPosition = 0;
            _scrollController.jumpTo(0);
          } else {
            _scrollPosition += 0.3;
            _scrollController.jumpTo(_scrollPosition.clamp(0.0, maxScroll));
          }
        }
      },
    );
  }

  void _pauseAutoScroll() {
    setState(() {
      _isScrolling = true;
    });

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScrolling = false;
        });
        _scrollPosition = _scrollController.position.pixels;
      }
    });
  }

  void _onScroll() {
    _pauseAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.jobs.isEmpty) {
      return const SizedBox.shrink();
    }

    final repeatedJobs = [...widget.jobs, ...widget.jobs, ...widget.jobs];

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
            height: 320,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  _onScroll();
                }
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(
                  left: AppTheme.spacing4 + MediaQuery.of(context).padding.left,
                  right:
                      AppTheme.spacing4 + MediaQuery.of(context).padding.right,
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
          ),
        ],
      ),
    );
  }
}
