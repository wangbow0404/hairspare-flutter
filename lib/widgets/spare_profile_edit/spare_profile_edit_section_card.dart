import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 프로필 수정 — 흰 카드 섹션 래퍼.
class SpareProfileEditSectionCard extends StatelessWidget {
  const SpareProfileEditSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.stitchSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppTheme.spacing1),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.stitchTextSecondary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spacing4),
          child,
        ],
      ),
    );
  }
}
