import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';

/// 일반 공고 섹션 (페이지네이션 포함)
class NormalJobsSection extends StatefulWidget {
  final List<Job> jobs;
  final Function(Job)? onJobTap;
  final Function(String, bool)? onFavoriteToggle;
  final Map<String, bool> favoriteMap;

  const NormalJobsSection({
    super.key,
    required this.jobs,
    this.onJobTap,
    this.onFavoriteToggle,
    required this.favoriteMap,
  });

  @override
  State<NormalJobsSection> createState() => _NormalJobsSectionState();
}

class _NormalJobsSectionState extends State<NormalJobsSection> {
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

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

  int get _totalPages {
    return (widget.jobs.length / _itemsPerPage).ceil();
  }

  List<Job> get _currentPageJobs {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return widget.jobs.sublist(
      startIndex,
      endIndex > widget.jobs.length ? widget.jobs.length : endIndex,
    );
  }

  List<int> get _visiblePageNumbers {
    const maxVisible = 5;
    final totalPages = _totalPages;

    if (totalPages <= maxVisible) {
      return List.generate(totalPages, (i) => i + 1);
    }

    if (_currentPage <= 3) {
      return List.generate(maxVisible, (i) => i + 1);
    } else if (_currentPage >= totalPages - 2) {
      return List.generate(maxVisible, (i) => totalPages - maxVisible + i + 1);
    } else {
      return List.generate(maxVisible, (i) => _currentPage - 2 + i);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.jobs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.borderGray,
            width: 1,
          ),
        ),
      ),
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Text(
                '일반 공고',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(width: AppTheme.spacing2),
              Container(
                padding: EdgeInsets.all(AppTheme.spacing1),
                decoration: BoxDecoration(
                  color: AppTheme.borderGray300,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                ),
                child: IconMapper.icon(
                  'info',
                  size: 16,
                  color: AppTheme.textGray700,
                ) ??
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppTheme.textGray700,
                    ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          // 공고 리스트 (페이지당 10개)
          Column(
            children: _currentPageJobs.map((job) {
              final isFavorite = widget.favoriteMap[job.id] ?? false;
              final daysLeft = _getDaysLeft(job);
              final isShortTerm = daysLeft == 0;
              final timeTag = _getTimeTag(job.time);

              return Container(
                margin: EdgeInsets.only(bottom: AppTheme.spacing3),
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
                    child: Stack(
                      children: [
                        Padding(
                          padding: AppTheme.spacing(AppTheme.spacing4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 이미지 영역
                              Container(
                                width: 80, // w-20
                                height: 80, // h-20
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.green200,
                                      AppTheme.primaryBlue.withOpacity(0.3),
                                    ],
                                  ),
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                ),
                              ),
                              SizedBox(width: AppTheme.spacing3),
                              // 내용 영역
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 태그 영역
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
                                    SizedBox(height: AppTheme.spacing1),
                                    // 날짜, 금액, 설명
                                    Wrap(
                                      spacing: AppTheme.spacing2,
                                      runSpacing: AppTheme.spacing1,
                                      children: [
                                        Text(
                                          '${job.date} ${job.time}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
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
                                    SizedBox(height: AppTheme.spacing1),
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
                        // 찜 버튼 - 우측 상단
                        Positioned(
                          top: AppTheme.spacing4,
                          right: AppTheme.spacing4,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                widget.onFavoriteToggle?.call(job.id, isFavorite);
                              },
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                              child: Container(
                                padding: EdgeInsets.all(AppTheme.spacing2),
                                child: IconMapper.icon(
                                  'heart',
                                  size: 20,
                                  color: isFavorite
                                      ? AppTheme.urgentRed
                                      : AppTheme.textTertiary,
                                ) ??
                                    Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      size: 20,
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
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: AppTheme.spacing6),
          // 페이지네이션
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 페이지네이션 컨트롤
              Row(
                children: [
                  // 이전 버튼
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _currentPage > 1
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      child: Container(
                        padding: EdgeInsets.all(AppTheme.spacing2),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.borderGray300),
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                        ),
                        child: IconMapper.icon(
                          'chevronleft',
                          size: 20,
                          color: _currentPage > 1
                              ? AppTheme.textSecondary
                              : AppTheme.textTertiary,
                        ) ??
                            Icon(
                              Icons.chevron_left,
                              size: 20,
                              color: _currentPage > 1
                                  ? AppTheme.textSecondary
                                  : AppTheme.textTertiary,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing1),
                  // 페이지 번호 버튼들
                  Row(
                    children: _visiblePageNumbers.map((pageNum) {
                      final isActive = pageNum == _currentPage;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _currentPage = pageNum;
                            });
                          },
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.primaryBlue
                                  : Colors.transparent,
                              border: Border.all(
                                color: isActive
                                    ? AppTheme.primaryBlue
                                    : AppTheme.borderGray300,
                              ),
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                            ),
                            child: Center(
                              child: Text(
                                '$pageNum',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isActive
                                      ? Colors.white
                                      : AppTheme.textGray700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: AppTheme.spacing1),
                  // 다음 버튼
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _currentPage < _totalPages
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      child: Container(
                        padding: EdgeInsets.all(AppTheme.spacing2),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.borderGray300),
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                        ),
                        child: IconMapper.icon(
                          'chevronright',
                          size: 20,
                          color: _currentPage < _totalPages
                              ? AppTheme.textSecondary
                              : AppTheme.textTertiary,
                        ) ??
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: _currentPage < _totalPages
                                  ? AppTheme.textSecondary
                                  : AppTheme.textTertiary,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              // 더보기 버튼
              ElevatedButton(
                onPressed: () {
                  // TODO: 공고 더보기 화면으로 이동
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: AppTheme.spacingSymmetric(
                    horizontal: AppTheme.spacing4,
                    vertical: AppTheme.spacing2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  ),
                ),
                child: Text(
                  '더보기',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
