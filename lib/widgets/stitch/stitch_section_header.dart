import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Stitch 홈 섹션 헤더 — 제목 + 부제 + 전체보기.
class StitchSectionHeader extends StatelessWidget {
  const StitchSectionHeader({
    super.key,
    required this.title,
    this.titleHighlight,
    this.subtitle,
    this.viewAllLabel = '전체보기',
    this.onViewAll,
  });

  final String title;
  final String? titleHighlight;
  final String? subtitle;
  final String viewAllLabel;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.stitchTextPrimary,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(text: title),
                    if (titleHighlight != null)
                      TextSpan(
                        text: titleHighlight,
                        style: const TextStyle(color: AppTheme.urgentRed),
                      ),
                  ],
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppTheme.spacing1),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.stitchTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  viewAllLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.stitchTextSecondary,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppTheme.stitchTextSecondary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
