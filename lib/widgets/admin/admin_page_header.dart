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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontSize: 30,
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
              ),
            ],
          ],
        ),
        Row(
          children: [
            if (showLiveBadge) ...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '실시간 업데이트 중',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
              SizedBox(width: AppTheme.spacing4),
            ],
            if (trailing != null) trailing!,
          ],
        ),
      ],
    );
  }
}
