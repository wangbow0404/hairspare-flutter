import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'admin_stitch_widgets.dart';

/// 관리자 페이지 헤더 — [AdminStitchPageHeader] 위임 (타이포 통일)
class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showLiveBadge = false,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final bool showLiveBadge;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (trailing == null && !showLiveBadge) {
      return AdminStitchPageHeader(title: title, subtitle: subtitle);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AdminStitchPageHeader(title: title, subtitle: subtitle),
        ),
        if (showLiveBadge || trailing != null) ...[
          const SizedBox(width: AppTheme.spacing2),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLiveBadge) ...[
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Text(
                    '실시간 업데이트 중',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(width: AppTheme.spacing2),
                ],
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ],
      ],
    );
  }
}
