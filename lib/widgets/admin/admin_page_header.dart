import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 관리자 페이지 헤더 (제목 + 설명 + 실시간 업데이트 표시)
class AdminPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showLiveBadge;
  final Widget? trailing;

  const AdminPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showLiveBadge = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          fontSize: isNarrow ? 22 : 30,
                        ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppTheme.spacing2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: AppTheme.spacing2),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
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
                    Flexible(
                      child: Text(
                        '실시간 업데이트 중',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing2),
                  ],
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
