import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 스페어 [MyApplicationsScreen] 필터 칩과 동일 — 선택 시 보라 채움.
class ShopApplicantsFilterChip extends StatelessWidget {
  const ShopApplicantsFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppTheme.spacingSymmetric(
          horizontal: AppTheme.spacing3,
          vertical: AppTheme.spacing2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : AppTheme.backgroundGray,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
        ),
      ),
    );
  }
}
