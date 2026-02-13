import 'dart:async';
import 'package:flutter/material.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';
import 'package:intl/intl.dart';

/// 인기 공고 섹션 (가로 스크롤, 무한 스크롤, 자동 스크롤)
class PopularJobsSection extends StatefulWidget {
  final List<Job> jobs;
  final Function(Job)? onJobTap;
  final Function(String, bool)? onFavoriteToggle;
  final Map<String, bool> favoriteMap;

  const PopularJobsSection({
    super.key,
    required this.jobs,
    this.onJobTap,
    this.onFavoriteToggle,
    required this.favoriteMap,
  });

  @override
  State<PopularJobsSection> createState() => _PopularJobsSectionState();
}

class _PopularJobsSectionState extends State<PopularJobsSection>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;
  Timer? _autoScrollTimer;
  late AnimationController _animationController;
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(days: 1), // 무한 스크롤을 위한 긴 duration
    );
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 자동 스크롤 시작 (0.3px/frame, 60fps 기준)
  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.jobs.isEmpty) return;

    // 초기 스크롤 위치 설정을 위해 첫 프레임 대기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        final cardWidth = 288.0 + AppTheme.spacing4; // 카드 너비 + 마진
        final oneThird = (widget.jobs.length * cardWidth) / 3;
        _scrollPosition = oneThird;
        _scrollController.jumpTo(oneThird);
      }
    });

    // 60fps 기준으로 0.3px/frame = 18px/초
    _autoScrollTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~60fps
      (timer) {
        if (!_isScrolling && mounted && _scrollController.hasClients) {
          final cardWidth = 288.0 + AppTheme.spacing4; // 카드 너비 + 마진
          final maxScroll = _scrollController.position.maxScrollExtent;
          final currentScroll = _scrollController.position.pixels;
          
          // 무한 스크롤: 2/3 지점에 도달하면 1/3 지점으로 리셋
          final oneThird = maxScroll / 3;
          final twoThird = oneThird * 2;
          
          if (currentScroll >= twoThird) {
            _scrollPosition = oneThird;
            _scrollController.jumpTo(oneThird);
          } else {
            _scrollPosition += 0.3;
            if (_scrollPosition > maxScroll) {
              _scrollPosition = oneThird;
            }
            _scrollController.jumpTo(_scrollPosition);
          }
        }
      },
    );
  }

  // 자동 스크롤 일시 중지 (2초 후 재개)
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

  String _formatAmount(int amount) {
    return NumberFormat('#,###').format(amount);
  }

  int _getDaysLeft(Job job) {
    if (job.countdown == null) return 0;
    return (job.countdown! / 86400).floor();
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

  @override
  Widget build(BuildContext context) {
    if (widget.jobs.isEmpty) {
      return const SizedBox.shrink();
    }

    // 카드를 3번 반복하여 무한 스크롤 효과
    final repeatedJobs = [...widget.jobs, ...widget.jobs, ...widget.jobs];

    return Container(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '전체 인기 공고',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: 공고 더보기 화면으로 이동
                },
                child: Text(
                  '공고 더보기 >',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          // 가로 스크롤 리스트
          SizedBox(
            height: 280, // 카드 높이 + 여백
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
                itemCount: repeatedJobs.length,
                itemBuilder: (context, index) {
                  final job = repeatedJobs[index];
                  final isFavorite = widget.favoriteMap[job.id] ?? false;
                  final daysLeft = _getDaysLeft(job);
                  final isShortTerm = daysLeft == 0;
                  final timeTag = _getTimeTag(job.time);

                  return Container(
                    width: 288, // w-72 (72 * 4 = 288px)
                    margin: EdgeInsets.only(right: AppTheme.spacing4),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundWhite,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      border: Border.all(color: AppTheme.borderGray),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => widget.onJobTap?.call(job),
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 찜 버튼 - 우측 상단
                            Stack(
                              children: [
                                // 이미지 영역 (그라데이션)
                                Container(
                                  height: 128, // h-32
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.primaryBlue.withOpacity(0.3),
                                        AppTheme.primaryPurple.withOpacity(0.3),
                                        AppTheme.primaryPink.withOpacity(0.3),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(AppTheme.radiusLg),
                                      topRight: Radius.circular(AppTheme.radiusLg),
                                    ),
                                  ),
                                ),
                                // 찜 버튼
                                Positioned(
                                  top: AppTheme.spacing2,
                                  right: AppTheme.spacing2,
                                  child: Material(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                    child: InkWell(
                                      onTap: () {
                                        widget.onFavoriteToggle?.call(job.id, isFavorite);
                                      },
                                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                      child: Container(
                                        padding: EdgeInsets.all(AppTheme.spacing2),
                                        child: IconMapper.icon(
                                          'heart',
                                          size: 16,
                                          color: isFavorite
                                              ? AppTheme.urgentRed
                                              : AppTheme.textTertiary,
                                        ) ??
                                            Icon(
                                              isFavorite ? Icons.favorite : Icons.favorite_border,
                                              size: 16,
                                              color: isFavorite
                                                  ? AppTheme.urgentRed
                                                  : AppTheme.textTertiary,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // 내용 영역
                            Padding(
                              padding: AppTheme.spacing(AppTheme.spacing4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 태그 영역
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Wrap(
                                        spacing: AppTheme.spacing2,
                                        runSpacing: AppTheme.spacing1,
                                        children: [
                                          Container(
                                            padding: AppTheme.spacingSymmetric(
                                              horizontal: AppTheme.spacing2,
                                              vertical: AppTheme.spacing1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.green100,
                                              borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                                            ),
                                            child: Text(
                                              timeTag,
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.green700,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: AppTheme.spacingSymmetric(
                                              horizontal: AppTheme.spacing2,
                                              vertical: AppTheme.spacing1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isShortTerm
                                                  ? AppTheme.purple100
                                                  : AppTheme.backgroundGray,
                                              borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                                            ),
                                            child: Text(
                                              isShortTerm ? '단기' : '장기',
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isShortTerm
                                                    ? AppTheme.primaryPurple
                                                    : AppTheme.textGray700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (job.isUrgent ?? false)
                                        Container(
                                          padding: AppTheme.spacingSymmetric(
                                            horizontal: AppTheme.spacing2,
                                            vertical: AppTheme.spacing1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.urgentRed,
                                            borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                                          ),
                                          child: Text(
                                            '급구',
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: AppTheme.spacing2),
                                  // 매장명
                                  Text(
                                    job.shopName ?? '매장명 없음',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: AppTheme.spacing2),
                                  // 금액 및 정보
                                  Wrap(
                                    spacing: AppTheme.spacing2,
                                    runSpacing: AppTheme.spacing1,
                                    children: [
                                      Text(
                                        '${daysLeft}일 남음',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                      Text(
                                        '${_formatAmount(job.amount ?? 0)}원',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                      Text(
                                        '상당의 디자이너 헤어짓',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppTheme.spacing2),
                                  // 신청자 수
                                  Text(
                                    '신청 0/${job.requiredCount ?? 0}명',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
