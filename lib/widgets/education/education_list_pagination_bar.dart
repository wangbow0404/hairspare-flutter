import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class EducationListPaginationBar extends StatelessWidget {
  const EducationListPaginationBar({
    super.key,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.onPageChanged,
  });

  final int totalCount;
  final int currentPage;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  int get _totalPages {
    if (totalCount == 0) return 0;
    return (totalCount / pageSize).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _totalPages;
    if (totalPages <= 1) return const SizedBox.shrink();

    final start = (currentPage - 1) * pageSize + 1;
    final end = (currentPage * pageSize).clamp(0, totalCount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing3,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(top: BorderSide(color: AppTheme.borderGray)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '총 $totalCount개 중 $start-$end 표시',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.stitchTextSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: currentPage > 1
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                for (var page = 1; page <= totalPages; page++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      color: page == currentPage
                          ? AppTheme.stitchPrimaryContainer
                          : AppTheme.backgroundGray,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      child: InkWell(
                        onTap: () => onPageChanged(page),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$page',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: page == currentPage
                                  ? Colors.white
                                  : AppTheme.stitchTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: currentPage < totalPages
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
