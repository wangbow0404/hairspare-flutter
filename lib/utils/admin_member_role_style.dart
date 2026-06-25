import 'package:flutter/material.dart';

import '../theme/admin_stitch_theme.dart';
import '../theme/app_theme.dart';
import 'admin_member_role.dart';

/// [AdminMemberRole] 뱃지 색상 (UI 전용)
abstract final class AdminMemberRoleStyle {
  static Color badgeBackground(Map<String, dynamic> user) {
    if (AdminMemberRole.isShop(user)) {
      return AdminStitchTheme.secondaryContainer;
    }
    if (AdminMemberRole.isModel(user)) {
      return AppTheme.primaryPurple.withValues(alpha: 0.12);
    }
    if (AdminMemberRole.badgeLabel(user) == '디자이너') {
      return AdminStitchTheme.emerald.withValues(alpha: 0.12);
    }
    return AdminStitchTheme.surfaceVariant;
  }

  static Color badgeTextColor(Map<String, dynamic> user) {
    if (AdminMemberRole.isShop(user)) return AdminStitchTheme.secondary;
    if (AdminMemberRole.isModel(user)) return AppTheme.primaryPurple;
    if (AdminMemberRole.badgeLabel(user) == '디자이너') {
      return AdminStitchTheme.emerald;
    }
    return AdminStitchTheme.textSecondary;
  }

  static Color detailBadgeColor(Map<String, dynamic> user) {
    if (AdminMemberRole.isShop(user)) return AppTheme.primaryPurple;
    if (AdminMemberRole.isModel(user)) return AppTheme.primaryPurple;
    if (AdminMemberRole.badgeLabel(user) == '디자이너') {
      return Colors.green;
    }
    return Colors.blue;
  }
}
