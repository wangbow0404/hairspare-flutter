import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 지원 상태 정규화·라벨·색상 (API/mock 혼용 대응).
abstract final class ApplicationStatusUtils {
  static String normalize(String raw) {
    switch (raw) {
      case 'accepted':
        return 'approved';
      case 'pending':
      case 'approved':
      case 'rejected':
      case 'cancelled_contact_violation':
        return raw;
      default:
        return raw;
    }
  }

  static String label(String raw) {
    switch (normalize(raw)) {
      case 'pending':
        return '대기중';
      case 'approved':
        return '승인됨';
      case 'rejected':
        return '거절됨';
      case 'cancelled_contact_violation':
        return '위반 취소';
      default:
        return raw;
    }
  }

  static Color foreground(String raw) {
    switch (normalize(raw)) {
      case 'pending':
        return Colors.amber.shade800;
      case 'approved':
        return Colors.green.shade700;
      case 'rejected':
        return AppTheme.urgentRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  static Color background(String raw) {
    switch (normalize(raw)) {
      case 'pending':
        return Colors.amber.shade50;
      case 'approved':
        return Colors.green.shade50;
      case 'rejected':
        return AppTheme.urgentRed.withValues(alpha: 0.08);
      default:
        return AppTheme.backgroundGray;
    }
  }

  static Color border(String raw) {
    switch (normalize(raw)) {
      case 'pending':
        return Colors.amber.shade300;
      case 'approved':
        return Colors.green.shade300;
      case 'rejected':
        return AppTheme.urgentRed.withValues(alpha: 0.35);
      default:
        return AppTheme.borderGray;
    }
  }
}
