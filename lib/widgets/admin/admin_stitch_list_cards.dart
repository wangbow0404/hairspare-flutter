import 'package:flutter/material.dart';

import '../../theme/admin_stitch_theme.dart';
import 'admin_stitch_widgets.dart';

/// 범용 관리자 목록 카드
class AdminStitchSimpleListCard extends StatelessWidget {
  const AdminStitchSimpleListCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AdminStitchCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (iconColor ?? AdminStitchTheme.primary)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? AdminStitchTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AdminStitchTheme.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AdminStitchTheme.bodyMd.copyWith(
                    color: AdminStitchTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// M14 콘텐츠 모더레이션 카드
class AdminStitchContentCard extends StatelessWidget {
  const AdminStitchContentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isVideo,
    required this.onHide,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final bool isVideo;
  final VoidCallback onHide;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AdminStitchSimpleListCard(
      title: title,
      subtitle: subtitle,
      icon: isVideo ? Icons.videocam_outlined : Icons.comment_outlined,
      iconColor: AdminStitchTheme.statusError,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility_off_outlined),
            color: AdminStitchTheme.textSecondary,
            onPressed: onHide,
            tooltip: '숨김',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AdminStitchTheme.statusError,
            onPressed: onDelete,
            tooltip: '삭제',
          ),
        ],
      ),
    );
  }
}
