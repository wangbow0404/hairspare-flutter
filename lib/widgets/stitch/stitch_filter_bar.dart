import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';

/// 공고 목록 상단 — 전체 개수 + 새로고침 + 필터/칩 슬롯.
class StitchFilterBar extends StatelessWidget {
  const StitchFilterBar({
    super.key,
    required this.totalCount,
    required this.onRefresh,
    required this.dropdownRow,
    required this.chipRow,
    this.countLabel = '전체',
  });

  final int totalCount;
  final String countLabel;
  final VoidCallback onRefresh;
  final Widget dropdownRow;
  final Widget chipRow;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundWhite,
      padding: AppTheme.spacing(AppTheme.spacing3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$countLabel $totalCount개',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.stitchTextPrimary,
                ),
              ),
              IconButton(
                icon: IconMapper.icon(
                      'refresh',
                      size: 20,
                      color: AppTheme.stitchTextSecondary,
                    ) ??
                    const Icon(
                      Icons.refresh,
                      size: 20,
                      color: AppTheme.stitchTextSecondary,
                    ),
                onPressed: onRefresh,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing3),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: dropdownRow,
          ),
          const SizedBox(height: AppTheme.spacing3),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: chipRow,
          ),
        ],
      ),
    );
  }
}
