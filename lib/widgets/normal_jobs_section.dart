import 'package:flutter/material.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';
import '../utils/job_popularity.dart';
import 'stitch/stitch_list_job_card.dart';
import 'stitch/stitch_section_header.dart';

/// 일반 공고 섹션 (페이지네이션 포함)
class NormalJobsSection extends StatefulWidget {
  final List<Job> jobs;
  final Function(Job)? onJobTap;
  final Function(String, bool)? onFavoriteToggle;
  final Map<String, bool> favoriteMap;
  final Set<String> popularJobIds;
  final VoidCallback? onViewAll;

  const NormalJobsSection({
    super.key,
    required this.jobs,
    this.onJobTap,
    this.onFavoriteToggle,
    required this.favoriteMap,
    this.popularJobIds = const {},
    this.onViewAll,
  });

  @override
  State<NormalJobsSection> createState() => _NormalJobsSectionState();
}

class _NormalJobsSectionState extends State<NormalJobsSection> {
  int _currentPage = 1;
  static const int _itemsPerPage = 10;

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
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
      ),
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StitchSectionHeader(
            title: '일반 공고',
            onViewAll: widget.onViewAll,
          ),
          const SizedBox(height: AppTheme.spacing4),
          Column(
            children: _currentPageJobs.map((job) {
              final isFavorite = widget.favoriteMap[job.id] ?? false;
              return StitchListJobCard(
                job: job,
                isFavorite: isFavorite,
                showPopularBadge: JobPopularity.showsPopularBadge(
                  job,
                  widget.popularJobIds,
                ),
                onTap: () => widget.onJobTap?.call(job),
                onFavoriteToggle: () =>
                    widget.onFavoriteToggle?.call(job.id, isFavorite),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _PaginationControls(
            currentPage: _currentPage,
            totalPages: _totalPages,
            visiblePages: _visiblePageNumbers,
            onPageChanged: (page) => setState(() => _currentPage = page),
          ),
        ],
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.visiblePages,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final List<int> visiblePages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ArrowButton(
          icon: 'chevronleft',
          fallback: Icons.chevron_left,
          enabled: currentPage > 1,
          onTap: () => onPageChanged(currentPage - 1),
        ),
        const SizedBox(width: AppTheme.spacing1),
        ...visiblePages.map((pageNum) {
          final isActive = pageNum == currentPage;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Material(
              color: isActive ? AppTheme.stitchPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              child: InkWell(
                onTap: () => onPageChanged(pageNum),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isActive
                          ? AppTheme.stitchPrimary
                          : AppTheme.borderGray300,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Text(
                    '$pageNum',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          isActive ? Colors.white : AppTheme.stitchTextPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: AppTheme.spacing1),
        _ArrowButton(
          icon: 'chevronright',
          fallback: Icons.chevron_right,
          enabled: currentPage < totalPages,
          onTap: () => onPageChanged(currentPage + 1),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.fallback,
    required this.enabled,
    required this.onTap,
  });

  final String icon;
  final IconData fallback;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppTheme.stitchTextSecondary : AppTheme.textTertiary;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing2),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderGray300),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: IconMapper.icon(icon, size: 20, color: color) ??
              Icon(fallback, size: 20, color: color),
        ),
      ),
    );
  }
}
